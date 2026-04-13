class BrandHomesController < ApplicationController
  allow_unauthenticated_access only: :posturacorretta_home
  before_action :set_current_brand_home_context
  layout "brand_public"

  def posturacorretta_home
  end

  private
    def set_current_brand_home_context
      @webapp_domain = current_webapp_domain

      return redirect_to root_path, alert: "Dominio web app non disponibile." if @webapp_domain.blank?

      @brand_port = @webapp_domain.brand_port
      @brand_network_ports = @brand_port.profile.ports.where(brand_port_id: @brand_port.id).order(:port_kind, :name)
    end
end
