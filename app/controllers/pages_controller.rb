class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home about]
  layout "brand_public", only: %i[home about]

  def home
    if unresolved_public_brand_domain?
      return render :domain_not_configured, status: :not_found
    end

    if current_brand_domain.present?
      return render_brand_domain_home
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
      { label: "Blog", href: blog_path }
    ]
  end

  def about
    @public_nav_links = [
      { label: "Home", href: root_path },
      { label: "About", href: about_path },
      { label: "Blog", href: blog_path }
    ]
  end

  private
    def unresolved_public_brand_domain?
      Rails.env.production? && resolved_domain_host.present? && resolved_domain_host != "flowpulse.net" && current_brand_domain.blank?
    end

    def render_brand_domain_home
      @brand_domain = current_brand_domain
      @brand_port = @brand_domain.brand_port

      if @brand_domain.home_page_key.present?
        custom_home_path = brand_home_path_for(@brand_domain.home_page_key)
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
      @port = @brand_port
      @brand_domains = @brand_port.brand_domains.where(published: true).order(primary: :desc, locale: :asc)
      @brand_nav_routes =
        @brand_port.outgoing_sea_routes
          .includes(:target_port)
          .ordered
          .select { |route| route.target_port.published? }
    end
end
