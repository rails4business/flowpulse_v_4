class LeadsController < ApplicationController
  before_action :set_lead

  def impegno
    @eventdates =
      Eventdate
        .where(lead_id: @lead.id)
        .order(Arel.sql("eventdates.date_start DESC NULLS LAST"))
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

    # Grouped Select Data
    domains = Domain.includes(:taxbranch).map { |d| [d.host, d.taxbranch_id] }
    services = Service.includes(:taxbranch).map { |s| [s.slug, s.taxbranch_id] }
    branches = Taxbranch.limit(200).map { |t| [t.slug, t.id] }

    @grouped_taxbranch_options = {
      "Domini" => domains,
      "Servizi" => services,
      "Branch" => branches
    }
  end

  def create_expense_check
    eventdate = Eventdate.create!(
      lead: @lead,
      taxbranch: @lead.taxbranches.first,
      description: "Spesa",
      event_type: :check,
      status: :completed,
      date_start: Time.current
    )

    redirect_to impegno_lead_path(@lead, tab: "soldi", expense_eventdate_id: eventdate.id, expense_modal: 1)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to impegno_lead_path(@lead, tab: "soldi"),
                alert: e.message
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end
end
