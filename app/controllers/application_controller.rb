class ApplicationController < ActionController::Base
  include Authentication
  before_action :redirect_canonical_domain_alias
  before_action :update_development_domain_override
  before_action :update_workspace_override
  before_action :set_current_domain_context
  before_action :ensure_profile_completed
  helper_method :current_workspace_mode,
    :available_workspace_modes,
    :workspace_landing_path,
    :current_creator_carta_nautica_path,
    :current_creator_brand_tree_path,
    :current_webapp_brand_port,
    :dashboard_entry_path_for_flowpulse,
    :dashboard_entry_path_for_webapp_domain,
    :creator_world_switch_options,
    :creator_world_switch_current_target,
    :current_webapp_domain,
    :resolved_domain_host,
    :creator_owner_for_port?,
    :development_domain_simulation_active?,
    :development_domain_switch_host,
    :development_domain_switch_options,
    :development_domain_switch_query_params,
    :current_domain_context_type,
    :flowpulse_domain_context?,
    :webapp_domain_context?
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
      webapp_domain =
        if host == "flowpulse.net"
          nil
        else
          WebappDomain.includes(:brand_port).find_by(host: host, published: true)
        end

      Current.resolved_domain_host = host
      Current.webapp_domain = webapp_domain
      Current.domain_context_type = webapp_domain.present? ? "webapp_domain" : "flowpulse"
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

    def current_webapp_domain
      Current.webapp_domain
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

    def webapp_domain_context?
      current_domain_context_type == "webapp_domain"
    end

    def development_domain_simulation_active?
      Rails.env.development? && localhost_host?(normalize_domain_host(request.host))
    end

    def update_development_domain_override
      return unless Rails.env.development?
      return unless localhost_host?(normalize_domain_host(request.host))
      return unless params.key?(:_domain)

      requested_domain = params[:_domain].to_s.strip

      if requested_domain.blank? || requested_domain.downcase == "reset"
        session.delete(:dev_domain_host)
      else
        session[:dev_domain_host] = normalize_domain_host(requested_domain)
      end
    end

    def update_workspace_override
      return unless params.key?(:_workspace)

      requested_mode = params[:_workspace].to_s.strip
      allowed_modes = available_workspace_modes.map { |workspace| workspace[:key] }
      return unless allowed_modes.include?(requested_mode)

      session[:workspace_mode] = requested_mode
    end

    def require_superadmin
      return if Current.session.user.superadmin?

      redirect_to dashboard_path, alert: "Accesso riservato al superadmin."
    end

    def current_workspace_mode
      requested_mode = session[:workspace_mode].presence&.to_s
      available_modes = available_workspace_modes.map { |mode| mode[:key] }

      return requested_mode if available_modes.include?(requested_mode)
      if webapp_domain_context? && available_modes.include?("traveler")
        "traveler"
      elsif flowpulse_domain_context? && available_modes.include?("creator")
        "creator"
      elsif flowpulse_domain_context? && available_modes.include?("superadmin")
        "superadmin"
      else
        available_modes.first || "creator"
      end
    end

    def available_workspace_modes
      modes = []

      if flowpulse_domain_context?
        modes << { key: "creator", label: "Creator" } if Current.session.user.profile&.creator?
        modes << { key: "superadmin", label: "Superadmin" } if Current.session.user.superadmin?
      else
        modes << { key: "traveler", label: "Viaggiatore" }
        modes << { key: "creator", label: "Creator" } if Current.session.user.profile&.creator?
        modes << { key: "professional", label: "Professionista" } if Current.session.user.profile&.professional?
      end

      modes = [{ key: "traveler", label: "Viaggiatore" }] if modes.empty? && webapp_domain_context?
      modes = [{ key: "creator", label: "Creator" }] if modes.empty? && flowpulse_domain_context?

      modes
    end

    def workspace_landing_path(mode = current_workspace_mode)
      case mode.to_s
      when "traveler"
        webapp_domain_context? ? traveler_impegno_path : dashboard_path
      when "creator"
        current_creator_carta_nautica_path
      when "professional"
        webapp_domain_context? ? professionals_path : dashboard_path
      when "superadmin"
        admin_creator_requests_path
      else
        dashboard_path
      end
    end

    def current_creator_carta_nautica_path(extra_params = {})
      params_hash = extra_params.compact

      if webapp_domain_context? && current_webapp_brand_port.present?
        creator_brand_carta_nautica_path(brand_port_id: current_webapp_brand_port.id, **params_hash)
      else
        creator_carta_nautica_path(params_hash)
      end
    end

    def current_creator_brand_tree_path
      if webapp_domain_context? && current_webapp_brand_port.present?
        creator_brand_tree_path(root_brand_id: current_webapp_brand_port.id, scope: "subtree")
      else
        creator_brand_tree_path(scope: "all")
      end
    end

    def current_webapp_brand_port
      return nil if current_webapp_domain.blank?

      webapp_port = current_webapp_domain.brand_port
      webapp_port&.inherited_brand_port || webapp_port
    end

    def resolve_domain_host
      actual_host = normalize_domain_host(request.host)

      return actual_host unless Rails.env.development?
      return actual_host unless localhost_host?(actual_host)

      normalize_domain_host(session[:dev_domain_host].presence || "flowpulse.net")
    end

    def development_domain_switch_host
      resolve_domain_host
    end

    def development_domain_switch_options
      return [] unless development_domain_simulation_active?

      flowpulse_option = [["Flowpulse", "flowpulse.net"]]
      published_domains = WebappDomain.where(published: true).includes(:brand_port).order(:host).map do |webapp_domain|
        label = webapp_domain.title.presence || webapp_domain.brand_port&.name.presence || webapp_domain.host
        ["#{label} · #{webapp_domain.host}", webapp_domain.host]
      end

      flowpulse_option + published_domains.uniq { |(_, host)| host }
    end

    def development_domain_switch_query_params
      request.query_parameters.except("_domain")
    end

    def dashboard_entry_path_for_webapp_domain(webapp_domain)
      return dashboard_path if webapp_domain.blank?

      if Rails.env.development? && localhost_host?(normalize_domain_host(request.host))
        dashboard_path(_domain: webapp_domain.host)
      else
        dashboard_url(host: webapp_domain.host)
      end
    end

    def dashboard_entry_path_for_flowpulse
      if Rails.env.development? && localhost_host?(normalize_domain_host(request.host))
        dashboard_path(_domain: "flowpulse.net")
      else
        dashboard_url(host: "flowpulse.net")
      end
    end

    def creator_world_switch_options
      return [] unless Rails.env.production?
      return [] unless Current.session.user.profile&.creator?

      options = [["Flowpulse", append_workspace_query(dashboard_entry_path_for_flowpulse, "creator")]]

      brand_ports = Current.session.user.profile.ports.where(brand_root: true).includes(:webapp_domains)
      brand_ports.each do |brand_port|
        primary_domain =
          brand_port.webapp_domains.detect { |domain| domain.published? && domain.primary? } ||
          brand_port.webapp_domains.detect(&:published?)
        next if primary_domain.blank?

        label = primary_domain.title.presence || brand_port.name
        options << ["#{label} · #{primary_domain.host}", append_workspace_query(dashboard_entry_path_for_webapp_domain(primary_domain), "creator")]
      end

      options.uniq { |(_, target)| target }
    end

    def creator_world_switch_current_target
      if webapp_domain_context? && current_webapp_domain.present?
        append_workspace_query(dashboard_entry_path_for_webapp_domain(current_webapp_domain), "creator")
      else
        append_workspace_query(dashboard_entry_path_for_flowpulse, "creator")
      end
    end

    def normalize_domain_host(value)
      value.to_s.strip.downcase.sub(/\Awww\./, "")
    end

    def localhost_host?(host)
      host.in?(["localhost", "127.0.0.1", "0.0.0.0"])
    end

    def append_workspace_query(url, workspace)
      separator = url.include?("?") ? "&" : "?"
      "#{url}#{separator}_workspace=#{workspace}"
    end

    def creator_owner_for_port?(port)
      return false unless authenticated?
      return false unless Current.session.user.profile&.creator?
      return false if port.blank?

      port.profile == Current.session.user.profile
    end
end
