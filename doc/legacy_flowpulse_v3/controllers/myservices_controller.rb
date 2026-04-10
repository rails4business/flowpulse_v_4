class MyservicesController < ApplicationController
  before_action :require_authenticated_lead

  def index
    @lead = Current.user.lead
    @enrollments = @lead.enrollments.includes(:service, :journey).order(created_at: :desc)
    @services = @enrollments.map(&:service).compact.uniq
    @enrollments_by_service = @enrollments.group_by(&:service)
  end

  private

  def require_authenticated_lead
    unless Current.user&.lead
      redirect_to account_leads_path, alert: "Completa il profilo Lead per accedere ai tuoi servizi."
    end
  end
end
