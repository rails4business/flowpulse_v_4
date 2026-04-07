class DashboardsController < ApplicationController
  def show
    if Current.session.user.profile.blank?
      redirect_to new_profile_path, notice: "Completa prima il profilo."
    end
  end

  def workspace
    mode = params[:mode].to_s
    allowed = available_workspace_modes.map { |workspace| workspace[:key] }

    session[:workspace_mode] = allowed.include?(mode) ? mode : available_workspace_modes.first&.dig(:key)
    redirect_back fallback_location: dashboard_path
  end
end
