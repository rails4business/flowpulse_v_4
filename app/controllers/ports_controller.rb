class PortsController < ApplicationController
  allow_unauthenticated_access only: :public
  layout "brand_public", only: :public

  def public
    @port = Port.includes(:profile, :webapp_domains).find(params[:id])
    @brand_port = current_webapp_domain&.brand_port || @port.inherited_brand_port || @port
    @webapp_domain = current_webapp_domain if current_webapp_domain&.brand_port_id == @brand_port.id
    @webapp_domains = @brand_port.webapp_domains.where(published: true).order(primary: :desc, locale: :asc)
    @brand_nav_routes =
      @brand_port.outgoing_sea_routes
        .includes(:target_port)
        .ordered
        .select { |route| route.target_port.published? }

    return if show_public_port?

    redirect_to root_path, alert: "Porto pubblico non disponibile."
  end

  private
    def show_public_port?
      return true if @port.published?
      return false if current_webapp_domain.blank?
      return false unless same_webapp_domain_perimeter?

      @port.published? || @port == current_webapp_domain.brand_port
    end

    def same_webapp_domain_perimeter?
      @port == current_webapp_domain.brand_port || @port.brand_port_id == current_webapp_domain.brand_port_id
    end
end
