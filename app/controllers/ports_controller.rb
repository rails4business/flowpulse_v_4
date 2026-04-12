class PortsController < ApplicationController
  allow_unauthenticated_access only: :public
  layout "brand_public", only: :public

  def public
    @port = Port.includes(:profile, :brand_domains).find(params[:id])
    @brand_port = current_brand_domain&.brand_port || @port.inherited_brand_port || @port
    @brand_domain = current_brand_domain if current_brand_domain&.brand_port_id == @brand_port.id
    @brand_domains = @brand_port.brand_domains.where(published: true).order(primary: :desc, locale: :asc)
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
      return false if current_brand_domain.blank?
      return false unless same_brand_domain_perimeter?

      @port.published? || @port == current_brand_domain.brand_port
    end

    def same_brand_domain_perimeter?
      @port == current_brand_domain.brand_port || @port.brand_port_id == current_brand_domain.brand_port_id
    end
end
