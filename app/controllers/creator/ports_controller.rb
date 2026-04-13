module Creator
  class PortsController < ApplicationController
    before_action :require_creator
    before_action :set_port, only: %i[ show edit update destroy ]

    def new
      @port = Current.session.user.profile.ports.new(
        x: params[:x],
        y: params[:y],
        brand_root: ActiveModel::Type::Boolean.new.cast(params[:brand_root]),
        brand_port_id: params[:brand_port_id]
      )
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
        redirect_to chart_redirect_path(@port), notice: route_source_port.present? ? "Porto creato e rotta nautica collegata." : "Porto creato con successo sulla tua carta nautica."
      else
        profile = Current.session.user.profile
        @brand_port = chart_brand_port_for(@port)
        if @brand_port.present?
          @ports = profile.ports.where(id: @brand_port.id).or(profile.ports.where(brand_port_id: @brand_port.id)).order(created_at: :desc)
        else
          @ports = profile.ports.where(brand_root: true).order(created_at: :desc)
        end
        visible_port_ids = @ports.pluck(:id)
        @sea_routes = profile.sea_routes.includes(:source_port, :target_port).where(source_port_id: visible_port_ids, target_port_id: visible_port_ids).order(created_at: :desc)
        @route_source_port_id = params[:route_source_port_id]
        render "creator/carta_nautica", status: :unprocessable_entity
      end
    end

    def update
      if @port.update(port_params)
        respond_to do |format|
          format.html { redirect_to chart_redirect_path(@port), notice: "Il porto è stato aggiornato." }
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
      redirect_path = chart_redirect_path(@port)
      @port.destroy
      redirect_to redirect_path, notice: "Porto rimosso definitivamente."
    end

    private
      def set_port
        @port = Current.session.user.profile.ports.find(params[:id])
      end

      def port_params
        params.require(:port).permit(:name, :slug, :port_kind, :visibility, :description, :entry_value, :brand_root, :brand_port_id, :color_key, :x, :y)
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
        return if port.brand_root?
        return if port.brand_port_id.present?

        inherited_brand = route_source_port.inherited_brand_port
        port.brand_port = inherited_brand if inherited_brand.present? && inherited_brand != port
      end

      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def chart_brand_port_for(port)
        return port if port.brand_root?

        port.brand_port
      end

      def chart_redirect_path(port)
        brand_port = chart_brand_port_for(port)
        return creator_carta_nautica_path(edit: 1) if brand_port.blank? || brand_port == port

        creator_brand_carta_nautica_path(brand_port_id: brand_port.id, edit: 1)
      end
  end
end
