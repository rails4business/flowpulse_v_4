module Creator
  class PortsController < ApplicationController
    before_action :require_creator
    before_action :set_port, only: %i[ show edit update destroy ]

    def new
      @port = Current.session.user.profile.ports.new(x: params[:x], y: params[:y])
      @route_source_port_id = params[:route_source_port_id]
    end

    def edit
    end

    def show
    end

    def create
      @port = Current.session.user.profile.ports.new(port_params)
      route_source_port = route_source_port_from_params
      apply_inherited_brand_port(@port, route_source_port)

      if @port.save
        create_route_from_source(route_source_port, @port) if route_source_port.present?
        redirect_to creator_carta_nautica_path(edit: 1), notice: route_source_port.present? ? "Porto creato e rotta nautica collegata." : "Porto creato con successo sulla tua carta nautica."
      else
        @ports = Current.session.user.profile.ports.order(created_at: :desc)
        @sea_routes = Current.session.user.profile.sea_routes.includes(:source_port, :target_port).order(created_at: :desc)
        @route_source_port_id = params[:route_source_port_id]
        render "creator/carta_nautica", status: :unprocessable_entity
      end
    end

    def update
      if @port.update(port_params)
        respond_to do |format|
          format.html { redirect_to creator_carta_nautica_path(edit: 1), notice: "Il porto è stato aggiornato." }
          format.json { render json: { status: 'ok', port: @port.as_json(only: [:id, :x, :y]) } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { errors: @port.errors }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @port.destroy
      redirect_to creator_carta_nautica_path(edit: 1), notice: "Porto rimosso definitivamente."
    end

    private
      def set_port
        @port = Current.session.user.profile.ports.find(params[:id])
      end

      def port_params
        params.require(:port).permit(:name, :slug, :port_kind, :visibility, :description, :brand_port_id, :color_key, :x, :y)
      end

      def route_source_port_from_params
        return if params[:route_source_port_id].blank?

        Current.session.user.profile.ports.find_by(id: params[:route_source_port_id])
      end

      def create_route_from_source(source_port, target_port)
        Current.session.user.profile.sea_routes.find_or_create_by!(
          source_port: source_port,
          target_port: target_port
        )
      end

      def apply_inherited_brand_port(port, route_source_port)
        return if route_source_port.blank?
        return if port.brand_port_id.present?

        inherited_brand = route_source_port.inherited_brand_port
        port.brand_port = inherited_brand if inherited_brand.present? && inherited_brand != port
      end

      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end
  end
end
