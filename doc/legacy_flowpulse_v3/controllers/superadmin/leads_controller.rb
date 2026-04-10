# app/controllers/superadmin/leads_controller.rb
class Superadmin::LeadsController < ApplicationController
  include Pundit::Authorization

  before_action :set_lead, only: %i[show edit update destroy approve rails4b generaimpresa impegno]

  # Pundit user (se usi Current.user)
  def pundit_user
    Current.user
  end

  def index
    authorize Lead
    
    # Base query
    leads_query = Lead.includes(:user).order(created_at: :desc)
    
    # Apply status filter
    status_filter = params[:status].presence || "pending"
    
    case status_filter
    when "pending"
      leads_query = leads_query.joins(:user).where(users: { state_registration: :pending })
    when "approved"
      leads_query = leads_query.joins(:user).where(users: { state_registration: :approved })
    when "rejected"
      leads_query = leads_query.joins(:user).where(users: { state_registration: :rejected })
    # "all" - no additional filter
    end
    
    # Apply search if present
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      leads_query = leads_query.where(
        "leads.email ILIKE ? OR leads.username ILIKE ? OR CAST(leads.id AS TEXT) LIKE ?",
        search_term, search_term, search_term
      )
    end
    
    @leads = leads_query.page(params[:page])
    
    # Calculate counts for badges
    @counts = {
      "all" => Lead.count,
      "pending" => Lead.joins(:user).where(users: { state_registration: :pending }).count,
      "approved" => Lead.joins(:user).where(users: { state_registration: :approved }).count,
      "rejected" => Lead.joins(:user).where(users: { state_registration: :rejected }).count
    }
  end

  def show
    authorize @lead
  end

  def new
    @lead = Lead.new
    authorize @lead
  end

  def create
    @lead = Lead.new(lead_params)
    authorize @lead
    if @lead.save
      redirect_to [ :superadmin, @lead ], notice: "Lead creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @lead
  end

  def update
    authorize @lead
    if @lead.update(lead_params)
      redirect_to [ :superadmin, @lead ], notice: "Lead aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lead
    @lead.destroy
    redirect_to superadmin_leads_path, notice: "Lead eliminato."
  end

  def approve
    authorize @lead, :approve?

    user = @lead.user || User.new(lead: @lead, email: @lead.email)
    user.state_registration = :approved
    user.approved_by_lead_id = Current.user&.lead_id if user.respond_to?(:approved_by_lead_id)

    if user.save
      redirect_to [ :superadmin, @lead ], notice: "Lead approvato."
    else
      redirect_to [ :superadmin, @lead ], alert: "Errore: #{user.errors.full_messages.to_sentence}"
    end
  end

  def rails4b
    authorize @lead
    @taxbranches = @lead.taxbranches.order(created_at: :desc)
  end

  def generaimpresa
    authorize @lead

    @journeys_scope = @lead.journeys
    @services_scope = Service.where(lead_id: @lead.id)

    journey_ids = @journeys_scope.pluck(:id)
    service_ids = @services_scope.pluck(:id)

    @journeys_count = @journeys_scope.count
    @eventdates_count = journey_ids.any? ? Eventdate.where(journey_id: journey_ids).count : 0

    enrollment_scope = Enrollment.none
    enrollment_scope = enrollment_scope.or(Enrollment.where(service_id: service_ids)) if service_ids.any?
    enrollment_scope = enrollment_scope.or(Enrollment.where(journey_id: journey_ids)) if journey_ids.any?
    @enrollments_count = enrollment_scope.count

    booking_scope = Booking.none
    booking_scope = booking_scope.or(Booking.where(service_id: service_ids)) if service_ids.any?
    booking_scope = booking_scope.or(
      journey_ids.any? ? Booking.joins(eventdate: :journey).where(journeys: { id: journey_ids }) : Booking.none
    )
    @bookings_count = booking_scope.count

    @certificates_count = Certificate.where(lead_id: @lead.id).count

    @enrollment_revenue_euro = enrollment_scope.sum("COALESCE(price_euro, 0)")
    @booking_revenue_euro = booking_scope.sum("COALESCE(price_euro, 0)")
    @public_revenue_euro = @enrollment_revenue_euro + @booking_revenue_euro
  end

  def impegno
    authorize @lead

    journey_ids = @lead.journeys.pluck(:id)
    commitments_scope =
      if journey_ids.any?
        Commitment.joins(eventdate: :journey).where(journeys: { id: journey_ids })
      else
        Commitment.none
      end

    @commitments_count = commitments_scope.count
    @total_minutes = commitments_scope.sum("COALESCE(commitments.duration_minutes, 0)")
    @total_compensation = commitments_scope.sum("COALESCE(commitments.compensation_euro, 0)")
    @recent_commitments = commitments_scope.includes(eventdate: :journey).order(created_at: :desc).limit(10)
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:email, :name, :referral_lead_id) # adatta ai tuoi campi
  end
end
