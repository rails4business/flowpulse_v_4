module Account
  class ProfilesController < ApplicationController
    before_action :ensure_authenticated_lead

    def show
      @user = Current.user
      @lead = @user.lead
      @enrollments = @lead.enrollments.includes(service: { taxbranch: :domains }).order(created_at: :desc)
      @domains_group = @enrollments.group_by(&:domain)
      @participant_roles = @enrollments.map(&:participant_role).compact.uniq
      @obtained_roles = @enrollments.select { |en| en.certified_at.present? }.map(&:target_role).compact.uniq
    end

    private

    def ensure_authenticated_lead
      unless Current.user&.lead
        redirect_to account_leads_path, alert: "Completa il profilo Lead per accedere a questa pagina."
      end
    end
  end
end
