class ApplicationController < ActionController::Base
  include Authentication
  before_action :ensure_profile_completed
  helper_method :current_workspace_mode, :available_workspace_modes
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def ensure_profile_completed
      return if public_flow_controller?
      return unless authenticated?
      return if Current.session.user.profile.present?
      return if controller_name == "profiles" && action_name.in?(%w[new create])

      redirect_to new_profile_path, notice: "Completa prima il profilo."
    end

    def public_flow_controller?
      return true if controller_name == "pages" && action_name.in?(%w[home about])
      return true if controller_name == "blog"
      return true if controller_name == "sessions" && action_name.in?(%w[new create destroy])
      return true if controller_name == "registrations" && action_name.in?(%w[new create])
      return true if controller_name == "passwords"

      false
    end

    def require_superadmin
      return if Current.session.user.superadmin?

      redirect_to dashboard_path, alert: "Accesso riservato al superadmin."
    end

    def current_workspace_mode
      requested_mode = session[:workspace_mode].presence&.to_s
      available_modes = available_workspace_modes.map { |mode| mode[:key] }

      return requested_mode if available_modes.include?(requested_mode)

      available_modes.first || "traveler"
    end

    def available_workspace_modes
      modes = [
        { key: "traveler", label: "Viaggiatore" }
      ]

      modes << { key: "creator", label: "Creator" } if Current.session.user.profile&.creator?
      modes << { key: "professional", label: "Professionista" }
      modes << { key: "superadmin", label: "Superadmin" } if Current.session.user.superadmin?
      modes
    end
end
