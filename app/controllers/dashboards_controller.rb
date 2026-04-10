class DashboardsController < ApplicationController
  def show
    if Current.session.user.profile.blank?
      redirect_to new_profile_path, notice: "Completa prima il profilo."
    end
  end

  def workspace
    mode = params[:mode].to_s
    allowed = available_workspace_modes.map { |workspace| workspace[:key] }

    selected_mode = allowed.include?(mode) ? mode : available_workspace_modes.first&.dig(:key)
    session[:workspace_mode] = selected_mode
    redirect_to workspace_landing_path(selected_mode)
  end
end
