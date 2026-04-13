module Creator
  class WebappDomainsController < ApplicationController
    before_action :require_creator
    before_action :set_brand_port
    before_action :set_webapp_domain, only: %i[edit update destroy toggle_published]

    def index
      @webapp_domains = @brand_port.webapp_domains.order(primary: :desc, created_at: :asc)
    end

    def new
      @webapp_domain = @brand_port.webapp_domains.new
    end

    def create
      @webapp_domain = @brand_port.webapp_domains.new(webapp_domain_params)

      if @webapp_domain.save
        redirect_to creator_port_path(@brand_port), notice: "Dominio web app creato."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @webapp_domain.update(webapp_domain_params)
        redirect_to creator_port_path(@brand_port), notice: "Dominio web app aggiornato."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @webapp_domain.destroy
      redirect_to creator_port_path(@brand_port), notice: "Dominio web app eliminato."
    end

    def toggle_published
      @webapp_domain.update!(published: !@webapp_domain.published?)

      redirect_back fallback_location: creator_port_path(@brand_port),
        notice: @webapp_domain.published? ? "Dominio pubblicato." : "Dominio riportato in draft."
    end

    private
      def set_brand_port
        @brand_port = Current.session.user.profile.ports.find(params[:port_id])
        return if @brand_port.web_app?

        redirect_to creator_port_path(@brand_port), alert: "I domini possono essere associati solo a una web app."
      end

      def set_webapp_domain
        @webapp_domain = @brand_port.webapp_domains.find(params[:id])
      end

      def webapp_domain_params
        params.require(:webapp_domain).permit(
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
