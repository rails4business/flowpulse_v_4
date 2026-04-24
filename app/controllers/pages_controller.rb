class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home about fondatore markpostura]
  layout "brand_public", only: %i[home about fondatore markpostura]

  def home
    if markpostura_gallery_domain?
      return redirect_to markpostura_path
    end

    if unresolved_public_webapp_domain?
      return render :domain_not_configured, status: :not_found
    end

    if current_webapp_domain.present?
      return render_webapp_domain_home
    end

    @pillars = [
      {
        title: "Creator",
        description: "Il creator costruisce un proprio mondo fatto di branch, mappe comuni, trail template e servizi."
      },
      {
        title: "Professionista",
        description: "Il professionista porta competenze, formazione, servizi e valore professionale dentro mappe, percorsi e servizi."
      },
      {
        title: "Persona",
        description: "La persona entra per un bisogno, un miglioramento o una ricerca di conoscenza e costruisce nel tempo le proprie mappe del mondo."
      }
    ]

    @journeys = [
      "Malattia / bisogno",
      "Benessere / miglioramento",
      "Conoscenza"
    ]

    @public_nav_links = [
      { label: "Home", href: root_path },
      { label: "About", href: about_path },
      { label: "Fondatore", href: fondatore_path },
      { label: "Blog", href: blog_path }
    ]
  end

  def about
    @public_nav_links = [
      { label: "Home", href: root_path },
      { label: "About", href: about_path },
      { label: "Fondatore", href: fondatore_path },
      { label: "Blog", href: blog_path }
    ]
  end

  def fondatore
    @public_nav_links = [
      { label: "Home", href: root_path },
      { label: "About", href: about_path },
      { label: "Fondatore", href: fondatore_path },
      { label: "Blog", href: blog_path }
    ]
  end

  def markpostura
  end

  def week_plan
  end

  def daily_plan
  end

  def prenotazioni
  end

  def hub
  end

  def hobby_goals
  end

  def active_paths
  end

  def shared_events
  end

  private
    def unresolved_public_webapp_domain?
      Rails.env.production? && resolved_domain_host.present? && resolved_domain_host != "flowpulse.net" && current_webapp_domain.blank?
    end

    def markpostura_gallery_domain?
      resolved_domain_host.to_s.downcase.in?(%w[markpostura.it markpostura.com])
    end

    def render_webapp_domain_home
      @webapp_domain = current_webapp_domain
      @brand_port = @webapp_domain.brand_port
      @port = @brand_port

      unless @port.public_webapp_ready?
        return redirect_to preview_creator_port_path(@port) if creator_owner_preview_allowed?

        return render :webapp_coming_soon, status: :ok
      end

      if @webapp_domain.home_page_key.present?
        custom_home_path = brand_home_path_for(@webapp_domain.home_page_key)
        return redirect_to custom_home_path if custom_home_path.present?
      end

      load_standard_brand_home_data
      render "ports/public", layout: "brand_public"
    end

    def brand_home_path_for(home_page_key)
      case home_page_key
      when "posturacorretta_home"
        posturacorretta_brand_home_path
      end
    end

    def load_standard_brand_home_data
      @webapp_domains = @brand_port.webapp_domains.where(published: true).order(primary: :desc, locale: :asc)
      @brand_nav_routes =
        @brand_port.outgoing_sea_routes
          .includes(target_port: :content)
          .ordered
          .select { |route| route.target_port.content&.publicly_visible? }
    end

    def creator_owner_preview_allowed?
      creator_owner_for_port?(@port)
    end
end
