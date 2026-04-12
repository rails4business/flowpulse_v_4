module Creator
  class BrandDomainsController < ApplicationController
    before_action :require_creator
    before_action :set_brand_port
    before_action :set_brand_domain, only: %i[edit update destroy toggle_published]

    def index
      @brand_domains = @brand_port.brand_domains.order(primary: :desc, created_at: :asc)
    end

    def new
      @brand_domain = @brand_port.brand_domains.new
    end

    def create
      @brand_domain = @brand_port.brand_domains.new(brand_domain_params)

      if @brand_domain.save
        redirect_to creator_port_path(@brand_port), notice: "Dominio brand creato."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @brand_domain.update(brand_domain_params)
        redirect_to creator_port_path(@brand_port), notice: "Dominio brand aggiornato."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @brand_domain.destroy
      redirect_to creator_port_path(@brand_port), notice: "Dominio brand eliminato."
    end

    def toggle_published
      @brand_domain.update!(published: !@brand_domain.published?)

      redirect_back fallback_location: creator_port_path(@brand_port),
        notice: @brand_domain.published? ? "Dominio pubblicato." : "Dominio riportato in draft."
    end

    private
      def set_brand_port
        @brand_port = Current.session.user.profile.ports.find(params[:port_id])
        return if @brand_port.brand?

        redirect_to creator_port_path(@brand_port), alert: "I domini possono essere associati solo a un brand."
      end

      def set_brand_domain
        @brand_domain = @brand_port.brand_domains.find(params[:id])
      end

      def brand_domain_params
        params.require(:brand_domain).permit(
          :host,
          :locale,
          :primary,
          :published,
          :title,
          :seo_title,
          :seo_description,
          :favicon_url,
          :square_logo_url,
          :horizontal_logo_url,
          :header_bg_color,
          :header_text_color,
          :accent_color,
          :background_color,
          :home_page_key,
          :custom_css
        )
      end

      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end
  end
end
