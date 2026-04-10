class JourneysController < ApplicationController
  layout -> { turbo_frame_request? ? "modal" : "application" }
  before_action :set_journey, only: %i[ show edit update destroy train carousel start_tracking stop_tracking instance_cycle clone_cycle rails4b generaimpresa impegno ]
  before_action :load_branch_links, only: %i[ show rails4b generaimpresa ]
  before_action :load_production_stats, only: %i[ show rails4b generaimpresa ]
  before_action :load_public_revenue_stats, only: %i[ show generaimpresa ]
   def start_tracking
    # evita di aprire due tracking contemporanei sullo stesso journey
    open_event = @journey.eventdates.where(date_end: nil).order(:created_at).last
    if open_event
      redirect_to journey_path(@journey), alert: "C'è già un evento in corso iniziato alle #{I18n.l(open_event.date_start, format: :short)}."
      return
    end

     event = @journey.eventdates.create!(
    date_start:  Time.current,
    lead_id:     Current.user.lead&.id,
    event_type:  :session,   # enum
    mode:        :online,    # enum
    visibility:  :internal_date, # enum
    status: :tracking, # enum (nota: 'draft' NON esiste in Eventdate)
    description: "Tracking iniziato" # NECESSARIA per la validazione!
  )

    redirect_to @journey, notice: "Tracking iniziato, scrivi cosa stai facendo."
  end

  def stop_tracking
    open_event = @journey.eventdates.where(date_end: nil).order(:created_at).last

    unless open_event
      redirect_to journey_path(@journey), alert: "Nessun evento in corso da chiudere."
      return
    end

    open_event.update!(date_end: Time.current)

    redirect_to edit_eventdate_path(open_event), notice: "Tracking completato."
  end

  # GET /journeys or /journeys.json
  def index
    if params[:filter].nil?
      @journeys = Journey.all
    else
      @journeys = Journey.where(kind: params[:filter])
    end
  end

  # GET /journeys/1 or /journeys/1.json
  def show
    @eventdates = @journey.eventdates.includes(commitments: [ :taxbranch, :bookings ])

    @enrollments = @journey.enrollments.includes(:contact)
  end

  def train
    @eventdates = @journey.eventdates.includes(:taxbranch, :child_journey).order(:position, :date_start, :id)
  end
  def instance_cycle
    @instance_cycles = @journey.child_journeys.process_instance_cycle.order(created_at: :desc)
    @template_events = @journey.eventdates.order(:date_start)
  end

  def clone_cycle
    template = @journey
    instance = template.child_journeys.build(
      title: "#{template.title} · cycle #{template.child_journeys.count + 1}",
      taxbranch_id: template.taxbranch_id,
      service_id: template.service_id,
      lead_id: template.lead_id,
      importance: template.importance,
      urgency: template.urgency,
      energy: template.energy,
      kind: :process_instance_cycle
    )
    if instance.save
      redirect_to instance_cycle_journey_path(template), notice: "Cycle creato dal template."
    else
      redirect_to journey_path(template), alert: instance.errors.full_messages.to_sentence
    end
  end

  def replicate_template_events
    cycle = @journey
    template = cycle.template_journey
    unless template
      redirect_back fallback_location: journey_path(cycle), alert: "Questo cycle non è collegato a un template."
      return
    end

    if cycle.eventdates.where("meta ? :key", key: "cloned_from_template_id").exists?
      redirect_back fallback_location: instance_cycle_journey_path(template), notice: "Gli eventi del template sono già stati replicati."
      return
    end

    template.eventdates.order(:date_start).each do |event|
      clone = cycle.eventdates.build(
        date_start: event.date_start,
        date_end: event.date_end,
        description: event.description,
        event_type: event.event_type,
        lead_id: cycle.lead_id || event.lead_id,
        location: event.location,
        mode: event.mode,
        visibility: event.visibility,
        status: event.status,
        taxbranch_id: event.taxbranch_id,
        meta: (event.meta || {}).merge("cloned_from_template_id" => event.id)
      )
      clone.save!
    end

    redirect_back fallback_location: instance_cycle_journey_path(template), notice: "Eventi duplicati dal template."
  end

  def clear_template_events
    cycle = @journey
    template = cycle.template_journey
    destroyed = cycle.eventdates.where("meta ? :key", key: "cloned_from_template_id").destroy_all
    redirect_back fallback_location: (template ? instance_cycle_journey_path(template) : journey_path(cycle)), notice: "#{destroyed.count} eventi rimossi."
  end


  def carousel
  end

  def rails4b
    @service = @journey.service
    @taxbranch = @journey.taxbranch
    @eventdates = @journey.eventdates.order(:date_start)
    @commitments = @journey.commitments.includes(:taxbranch)
  end


  def generaimpresa
    @enrollments = @journey.enrollments.includes(:mycontact)
    @enrollments_count = @enrollments.count
    @bookings_count = @journey.bookings.count
    @certificates_count = @journey.certificates.count
    @participants_per_role = @journey.enrollments.group(:role_name).count
  end

  def impegno
    # Calculate commitment stats for this journey
    @commitments = @journey.commitments.includes(:eventdate).order(created_at: :desc)
    @total_euro = @commitments.sum(:compensation_euro)
    @total_dash = @commitments.sum(:compensation_dash)
    @total_minutes = @commitments.sum(:duration_minutes)
  end

  # GET /journeys/new
  def new
    @journey = Current.user.lead.journeys.build
    @journey.taxbranch_id = params[:taxbranch_id] if params[:taxbranch_id].present?
    @journey.end_taxbranch_id = params[:end_taxbranch_id] if params[:end_taxbranch_id].present?
    @journey.service_id = params[:service_id] if params[:service_id].present?
    phase_param = params[:journeys_status].presence || params[:phase]
    if phase_param.present? && Journey.journeys_statuses.key?(phase_param.to_sym)
      @journey.journeys_status = phase_param
    end
  end

  # GET /journeys/1/edit
  def edit
  end

  # POST /journeys or /journeys.json
  def create
    if params.dig(:journey, :template_journey_id).present?
      template = Journey.find(params[:journey][:template_journey_id])
      attrs = template.slice(:title, :taxbranch_id, :service_id, :lead_id, :importance, :urgency, :energy)
                      .merge(kind: :process_instance_cycle, template_journey: template)
      @journey = Journey.new(attrs)
    else
      @journey = Journey.new(journey_params)
    end
    @journey.lead ||= Current.user&.lead

    respond_to do |format|
      if @journey.save
        format.html { redirect_to @journey, notice: "Journey was successfully created." }
        format.json { render :show, status: :created, location: @journey }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @journey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /journeys/1 or /journeys/1.json
  def update
    respond_to do |format|
      if @journey.update(journey_params)
        if @journey.service.present?
          format.html do
            redirect_to servicemaps_superadmin_service_path(@journey.service, tab: "builders"),
                        notice: "Journey was successfully updated.",
                        status: :see_other
          end
        else
          format.html { redirect_to @journey, notice: "Journey was successfully updated.", status: :see_other }
        end
        format.json { render :show, status: :ok, location: @journey }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @journey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journeys/1 or /journeys/1.json
  def destroy
    @journey.destroy!

    respond_to do |format|
      format.html { redirect_to journeys_path, notice: "Journey was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_journey
      @journey = Journey.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def journey_params
      params.expect(journey: [ :title, :slug, :taxbranch_id, :end_taxbranch_id, :service_id, :lead_id, :importance, :urgency, :energy, :progress, :notes, :price_estimate_euro, :price_estimate_dash, :meta, :template_journey_id, :start_at, :end_at, :kind, :journey_type, :journey_roles, :journey_roles_text, :allows_invite, :allows_request, :journeys_status, :phase, :mode ])
    end

    def load_branch_links
      @frontline_branch = @journey.taxbranch
    end

    def load_production_stats
      @production_cost_euro = @journey.commitments.sum("COALESCE(compensation_euro, 0)")
      @production_minutes = @journey.commitments.sum("COALESCE(duration_minutes, 0)")
    end

    def load_public_revenue_stats
      @enrollment_revenue_euro = @journey.enrollments.sum("COALESCE(price_euro, 0)")
      booking_scope = Booking.where(eventdate_id: @journey.eventdates.select(:id))
      @booking_revenue_euro = booking_scope.sum("COALESCE(price_euro, 0)")
      @public_revenue_euro = @enrollment_revenue_euro + @booking_revenue_euro
    end
end
