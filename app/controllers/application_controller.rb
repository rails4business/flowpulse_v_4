class ApplicationController < ActionController::Base
  include Authentication
  before_action :redirect_canonical_domain_alias
  before_action :set_current_domain_context
  before_action :ensure_profile_completed
  helper_method :current_workspace_mode,
    :available_workspace_modes,
    :workspace_landing_path,
    :current_brand_domain,
    :resolved_domain_host,
    :development_domain_simulation_active?,
    :current_domain_context_type,
    :flowpulse_domain_context?,
    :brand_domain_context?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def redirect_canonical_domain_alias
      return unless Rails.env.production?
      return unless request.host.to_s.downcase.start_with?("www.")

      redirect_to request.original_url.sub(%r{\A(https?://)www\.}i, "\\1"), status: :moved_permanently, allow_other_host: true
    end

    def set_current_domain_context
      host = resolve_domain_host
      brand_domain =
        if host == "flowpulse.net"
          nil
        else
          BrandDomain.includes(:brand_port).find_by(host: host, published: true)
        end

      Current.resolved_domain_host = host
      Current.brand_domain = brand_domain
      Current.domain_context_type = brand_domain.present? ? "brand_domain" : "flowpulse"
    end

    def ensure_profile_completed
      return if public_flow_controller?
      return unless authenticated?
      return if Current.session.user.profile.present?
      return if controller_name == "profiles" && action_name.in?(%w[new create])

      redirect_to new_profile_path, notice: "Completa prima il profilo."
    end

    def public_flow_controller?
      return true if controller_name == "pages" && action_name.in?(%w[home about])
      return true if controller_name == "brand_homes"
      return true if controller_name == "ports" && action_name == "public"
      return true if controller_name == "blog"
      return true if controller_name == "sessions" && action_name.in?(%w[new create destroy])
      return true if controller_name == "registrations" && action_name.in?(%w[new create])
      return true if controller_name == "passwords"

      false
    end

    def current_brand_domain
      Current.brand_domain
    end

    def resolved_domain_host
      Current.resolved_domain_host
    end

    def current_domain_context_type
      Current.domain_context_type.presence || "flowpulse"
    end

    def flowpulse_domain_context?
      current_domain_context_type == "flowpulse"
    end

    def brand_domain_context?
      current_domain_context_type == "brand_domain"
    end

    def development_domain_simulation_active?
      Rails.env.development? && localhost_host?(normalize_domain_host(request.host))
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
      modes << { key: "professional", label: "Professionista" } if Current.session.user.profile&.professional?
      modes << { key: "superadmin", label: "Superadmin" } if Current.session.user.superadmin?
      modes
    end

    def workspace_landing_path(mode = current_workspace_mode)
      case mode.to_s
      when "traveler"
        traveler_impegno_path
      when "creator"
        creator_carta_nautica_path
      when "professional"
        professionals_path
      when "superadmin"
        admin_creator_requests_path
      else
        dashboard_path
      end
    end

    def resolve_domain_host
      actual_host = normalize_domain_host(request.host)

      return actual_host unless Rails.env.development?
      return actual_host unless localhost_host?(actual_host)

      normalize_domain_host(Rails.configuration.x.simulated_domain_host.presence || "flowpulse.net")
    end

    def normalize_domain_host(value)
      value.to_s.strip.downcase.sub(/\Awww\./, "")
    end

    def localhost_host?(host)
      host.in?(["localhost", "127.0.0.1", "0.0.0.0"])
    end
end
