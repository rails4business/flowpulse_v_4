module Superadmin
class ServicesController < ApplicationController
  layout -> {
    next "modal" if turbo_frame_request?
    %w[rails4b servicemaps].include?(action_name) ? "generaimpresa" : "application"
  }
  before_action :set_service, only: %i[ show edit update destroy rails4b generaimpresa servicemaps ]
  before_action :load_taxbranch, only: %i[ index new create ]
  before_action :load_branches, only: %i[ show rails4b generaimpresa ]
  before_action :load_production_stats, only: %i[ show rails4b generaimpresa ]
  before_action :load_public_revenue_stats, only: %i[ show generaimpresa ]

  # GET /services or /services.json
  def index
    @services =
      if @taxbranch.present?
        Service.where(taxbranch_id: @taxbranch.id)
      else
        Service.all
      end

    if params[:phase].present? && Service::PHASES.key?(params[:phase].to_sym)
      phase_value = Service::PHASES[params[:phase].to_sym]
      @services = @services
        .where("enrollable_from_phase IS NULL OR enrollable_from_phase <= ?", phase_value)
        .where("enrollable_until_phase IS NULL OR enrollable_until_phase >= ?", phase_value)
    end
  end

  # GET /services/1 or /services/1.json
  def show
  end

  def rails4b
    load_servicemaps_data
    render :servicemaps
  end

  def generaimpresa
    @journeys_scope = @service.journeys
    @journeys_count = @journeys_scope.count
    @eventdates_count = @service.eventdates.count
    @enrollments_count = @service.enrollments.count
    @bookings_count = @service.bookings.count
    @certificates_count = @service.certificates.count
    @roles_breakdown = @service.enrollments.group(:role_name).count
  end

  def servicemaps
    redirect_to rails4b_superadmin_service_path(@service), status: :moved_permanently
  end

  # GET /services/new
  def new
    @service = Service.new(taxbranch_id: @taxbranch&.id, lead: Current.user&.lead)
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services or /services.json
  def create
    @service = Service.new(service_params)
    @service.taxbranch ||= @taxbranch if @taxbranch.present?
    @service.lead ||= Current.user&.lead

    respond_to do |format|
      if @service.save
        format.html { redirect_to [ :superadmin, @service ], notice: "Service was successfully created." }
        format.json { render :show, status: :created, location: [ :superadmin, @service ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to  [ :superadmin, @service ], notice: "Service was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    @service.destroy!

    respond_to do |format|
      format.html { redirect_to superadmin_services_path, notice: "Service was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.expect(service: [
        :name, :slug, :description, :n_eventdates_planned, :price_enrollment_euro,
        :price_ticket_dash, :min_tickets, :max_tickets, :open_by_journey,
        :taxbranch_id, :lead_id, :meta,
        :allowed_roles, :output_roles, :builders_roles, :drivers_roles, :verifier_roles,
        :auto_certificate, :require_booking_verification,
        :require_enrollment_verification, :image_url,
        :included_in_service_id, :content_md,
        :enrollable_from_phase, :enrollable_until_phase,
        { allowed_roles: [], output_roles: [], builders_roles: [], drivers_roles: [], verifier_roles: [] }
      ])
    end

    def load_branches
      @frontline_branch = @service.taxbranch
    end

    def load_production_stats
      commitments_scope = Commitment.joins(eventdate: :journey).where(journeys: { service_id: @service.id })
      @production_cost_euro = commitments_scope.sum("COALESCE(commitments.compensation_euro, 0)")
      @production_minutes = commitments_scope.sum("COALESCE(commitments.duration_minutes, 0)")
    end

    def load_public_revenue_stats
      @enrollment_revenue_euro = @service.enrollments.sum("COALESCE(price_euro, 0)")
      @booking_revenue_euro = @service.bookings.sum("COALESCE(price_euro, 0)")
      @public_revenue_euro = @enrollment_revenue_euro + @booking_revenue_euro
    end

    def load_taxbranch
      return unless params[:taxbranch_id].present?

      @taxbranch = Taxbranch.find(params[:taxbranch_id])
    end
end
end
  def load_servicemaps_data
    @main_taxbranch = @service.taxbranch
    @builders_journeys = @service.journeys.cycle_template.includes(:eventdates)
    @builders_journey = @builders_journeys.order(updated_at: :desc).first
    @fallback_journey = @service.journeys.includes(:eventdates).order(updated_at: :desc).first
    @all_service_journeys = @service.journeys.order(updated_at: :desc)
    @drivers_journeys = @service.journeys.cycle_instance
    journey_ids = @builders_journeys.select(:id, :taxbranch_id, :end_taxbranch_id)
    station_ids = journey_ids.flat_map { |j| [j.taxbranch_id, j.end_taxbranch_id] }.compact.uniq
    station_ids << @service.taxbranch_id if @service.taxbranch_id.present?
    station_ids.uniq!
    @stations = Taxbranch.where(id: station_ids)

    @journey_counts = if station_ids.any?
                        @builders_journeys.where(taxbranch_id: station_ids).group(:taxbranch_id).count
                      else
                        {}
                      end
    @journey_links = @builders_journeys
      .where(taxbranch_id: station_ids, end_taxbranch_id: station_ids)
      .where.not(end_taxbranch_id: nil)
      .select(:id, :taxbranch_id, :end_taxbranch_id)

    if @main_taxbranch&.respond_to?(:self_and_ancestors)
      @domain = @main_taxbranch.self_and_ancestors.includes(:domains).map(&:domains).flatten.first
    end
    @domain ||= Domain.first
  end
