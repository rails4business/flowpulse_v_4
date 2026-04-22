class DashboardsController < ApplicationController
  def show
    if Current.session.user.profile.blank?
      redirect_to new_profile_path, notice: "Completa prima il profilo."
      return
    end

    return unless flowpulse_domain_context?
    return unless Current.session.user.profile.creator?

    @creator_brand_port = Current.session.user.profile.ports.where(brand_root: true).order(:created_at).first
    @creator_webapp_domain = @creator_brand_port&.webapp_domains&.where(published: true)&.order(primary: :desc, created_at: :asc)&.first
  end

  def workspace
    mode = params[:mode].to_s
    allowed = available_workspace_modes.map { |workspace| workspace[:key] }

    selected_mode = allowed.include?(mode) ? mode : available_workspace_modes.first&.dig(:key)
    session[:workspace_mode] = selected_mode
    redirect_to workspace_landing_path(selected_mode)
  end
end
