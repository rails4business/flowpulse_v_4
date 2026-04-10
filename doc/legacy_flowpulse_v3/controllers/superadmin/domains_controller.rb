module Superadmin
  class DomainsController < ApplicationController
    include RequireSuperadmin

  layout "generaimpresa"
  before_action :set_domain, only: %i[ show edit update destroy rails4b testroute mapservice generaimpresa journey_map impegno create_station ]
  # GET /domains or /domains.json
  def index
    @domains = Domain.all
  end

  # GET /domains/1 or /domains/1.json
  def show
    @tab = params[:tab].presence_in(%w[overview services memberships]) || "overview"
    @main_taxbranch = @domain.taxbranch
    @domain_memberships = @domain.domain_memberships.includes(:lead, :certificates).order(primary: :desc, created_at: :desc)
    station_ids = @main_taxbranch ? [ @main_taxbranch.id ] + @main_taxbranch.children.pluck(:id) : []
    @services =
      if station_ids.any?
        Service.where(taxbranch_id: station_ids).includes(:taxbranch).order(:name, :id)
      else
        Service.none
      end
  end

  def testroute
    @main_taxbranch = @domain.taxbranch
    @stations = @main_taxbranch ? @main_taxbranch.children : Taxbranch.none
    station_ids = @stations.map(&:id)
    @station_lookup = @stations.index_by(&:id)
    @services =
      if station_ids.any?
        Service.where(taxbranch_id: station_ids).includes(:taxbranch, :journeys).order(updated_at: :desc)
      else
        Service.none
      end
    @journeys =
      if station_ids.any?
        Journey
          .where(taxbranch_id: station_ids)
          .or(Journey.where(end_taxbranch_id: station_ids))
          .includes(:eventdates)
          .order(updated_at: :desc)
      else
        Journey.none
      end
    @selected_journey = @journeys.find_by(id: params[:journey_id])
    @service_lookup = @services.index_by(&:id)
    @journey_lookup = @journeys.index_by(&:id)
    @route_items = parse_route_items(params[:route])
  end

  def rails4b
    redirect_to testroute_superadmin_domain_path(@domain, request.query_parameters)
  end

  def mapservice
    @main_taxbranch = @domain.taxbranch
    @stations = @main_taxbranch ? @main_taxbranch.children : Taxbranch.none
    station_ids = @stations.map(&:id)
    @services =
      if station_ids.any?
        Service.where(taxbranch_id: station_ids).includes(:taxbranch).order(updated_at: :desc)
      else
        Service.none
      end
    @stations_by_id = @stations.index_by(&:id)
    @services_by_station = @services.group_by(&:taxbranch_id)
    @journeys =
      if station_ids.any?
        Journey
          .where(taxbranch_id: station_ids, end_taxbranch_id: station_ids)
          .where.not(end_taxbranch_id: nil)
          .order(updated_at: :desc)
      else
        Journey.none
      end
    render :generaimpresa
  end

  def generaimpresa
    redirect_to mapservice_superadmin_domain_path(@domain, request.query_parameters)
  end

  def journey_map
    @main_taxbranch = @domain.taxbranch
    @stations = @main_taxbranch ? @main_taxbranch.children : Taxbranch.none
    station_ids = @stations.map(&:id)
    @station_lookup = @stations.index_by(&:id)
    @services =
      if station_ids.any?
        Service.where(taxbranch_id: station_ids).includes(:taxbranch).order(updated_at: :desc)
      else
        Service.none
      end
    @journeys =
      if station_ids.any?
        Journey
          .where(taxbranch_id: station_ids)
          .or(Journey.where(end_taxbranch_id: station_ids))
          .includes(:eventdates)
          .order(updated_at: :desc)
      else
        Journey.none
      end
    @selected_journey = @journeys.find_by(id: params[:journey_id])
  end



  def impegno
    @main_taxbranch = @domain.taxbranch
    subtree_ids = @main_taxbranch&.subtree_ids || []
    @eventdates =
      if subtree_ids.any?
        Eventdate
          .left_joins(:journey, :taxbranch, journey: :service)
          .where(
            "eventdates.taxbranch_id IN (:ids) OR journeys.taxbranch_id IN (:ids) OR journeys.end_taxbranch_id IN (:ids) OR services.taxbranch_id IN (:ids)",
            ids: subtree_ids
          )
          .select("eventdates.*")
          .distinct
          .order(Arel.sql("eventdates.date_start DESC NULLS LAST"))
      else
        Eventdate.none
      end
    @commitments =
      Commitment
        .joins(:eventdate)
        .where(eventdates: { id: @eventdates.except(:order).reselect(:id) })
        .order(created_at: :desc)
    @bookings =
      Booking
        .joins(:eventdate)
        .where(eventdates: { id: @eventdates.except(:order).reselect(:id) })
        .order(created_at: :desc)
    @enrollments =
      Enrollment
        .joins(:bookings)
        .where(bookings: { eventdate_id: @eventdates.except(:order).reselect(:id) })
        .distinct
        .order(created_at: :desc)
    @expense_eventdate = @eventdates.find_by(id: params[:expense_eventdate_id])
  end

  def create_expense_check
    lead = @domain.taxbranch&.lead || Current.user&.lead
    unless lead.present?
      redirect_to impegno_superadmin_domain_path(@domain, tab: "soldi"),
                  alert: "Lead non trovato per creare la spesa."
      return
    end

    eventdate = Eventdate.create!(
      lead: lead,
      taxbranch: @domain.taxbranch,
      description: "Spesa",
      event_type: :check,
      status: :completed,
      date_start: Time.current
    )

    redirect_to impegno_superadmin_domain_path(@domain, tab: "soldi", expense_eventdate_id: eventdate.id, expense_modal: 1)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to impegno_superadmin_domain_path(@domain, tab: "soldi"),
                alert: e.message
  end

  def create_station
    station_params = params.fetch(:station, {}).permit(:name, :service_name, :slug_category, :x, :y)
    label = station_params[:name].to_s.strip
    service_name = station_params[:service_name].presence || label
    slug_category = station_params[:slug_category].presence || "service"

    taxbranch =
      @domain.taxbranch.children.build(
        lead_id: Current.user&.lead&.id,
        slug_label: label,
        slug_category: slug_category,
        x_coordinated: station_params[:x],
        y_coordinated: station_params[:y]
      )

    Taxbranch.transaction do
      taxbranch.save!
      Service.create!(
        lead_id: Current.user&.lead&.id,
        taxbranch_id: taxbranch.id,
        name: service_name,
        description: "Servizio demo per #{service_name}"
      )
    end

    respond_to do |format|
      format.json { render json: { taxbranch_id: taxbranch.id }, status: :created }
      format.html do
        redirect_to mapservice_superadmin_domain_path(@domain, edit_map: 1),
                    notice: "Stazione creata."
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
      format.html do
        redirect_to mapservice_superadmin_domain_path(@domain, edit_map: 1),
                    alert: e.message
      end
    end
  end

  def create_railservice
    @domain ||= Domain.find_by(id: params[:id] || params[:domain_id])
    rail_params = params.fetch(:rail, {}).permit(:start_service_id, :end_service_id, :title)
    start_service = Service.find_by(id: rail_params[:start_service_id])
    end_service = Service.find_by(id: rail_params[:end_service_id])

    if start_service.nil? || end_service.nil?
      redirect_to mapservice_superadmin_domain_path(@domain, edit_map: 1, railservices: 1),
                  alert: "Seleziona due services validi."
      return
    end

    title = rail_params[:title].presence ||
      "#{start_service.name.presence || start_service.slug} → #{end_service.name.presence || end_service.slug}"

    Journey.create!(
      title: title,
      lead_id: Current.user&.lead&.id,
      taxbranch_id: start_service.taxbranch_id,
      end_taxbranch_id: end_service.taxbranch_id,
      service_id: start_service.id,
      kind: :process,
      journey_type: :work,
      journeys_status: :problema
    )

    redirect_to mapservice_superadmin_domain_path(@domain),
                notice: "Railservice creato."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to mapservice_superadmin_domain_path(@domain, edit_map: 1, railservices: 1),
                alert: e.message
  end

  # GET /domains/new
  def new
   prefilled_taxbranch_id = params[:taxbranch_id].presence || params[:parent_id].presence
   @domain = Domain.new(taxbranch_id: prefilled_taxbranch_id)
   @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
  end

  # GET /domains/1/edit
  def edit
       @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
  end

  # POST /domains or /domains.json
  def create
    @domain = Domain.new(domain_params)

  @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none


    respond_to do |format|
      if @domain.save
        format.html { redirect_to [ :superadmin, @domain ], notice: "Domain was successfully created." }
        format.json { render :show, status: :created, location: [ :superadmin, @domain ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
       @taxbranches = Current.user&.lead&.taxbranches&.ordered || Taxbranch.none
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to [ :superadmin, @domain ], notice: "Domain was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [ :superadmin, @domain ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1 or /domains/1.json
  def destroy
    taxbranch = @domain.taxbranch
    @domain.destroy!

    respond_to do |format|
      format.html do
        if taxbranch.present?
          redirect_to superadmin_taxbranch_path(taxbranch), notice: "Domain was successfully destroyed.", status: :see_other
        else
          redirect_to superadmin_domains_path, notice: "Domain was successfully destroyed.", status: :see_other
        end
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def domain_params
      params.expect(domain: [ :host, :language, :title, :description, :favicon_url, :square_logo_url, :horizontal_logo_url, :provider, :taxbranch_id, :operative_roles ])
    end

    def parse_route_items(route_param)
      return [] if route_param.blank?
      parts = route_param.to_s.split("_")
      parts.filter_map do |part|
        type, raw_id = part.split("-", 2)
        id = raw_id.to_i
        next if id.zero?
        case type
        when "service"
          record = @service_lookup[id] || Service.find_by(id: id)
          next unless record
          { type: :service, id: id, record: record }
        when "rail", "journey"
          record = @journey_lookup[id] || Journey.find_by(id: id)
          next unless record
          { type: :rail, id: id, record: record }
        end
      end
    end
  end
end
