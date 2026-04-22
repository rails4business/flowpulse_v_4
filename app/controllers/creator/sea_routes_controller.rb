module Creator
  class SeaRoutesController < ApplicationController
    before_action :require_creator
    before_action :set_sea_route, only: [:update, :destroy, :cycle_direction, :invert_direction, :set_direction]

    def create
      @sea_route = Current.session.user.profile.sea_routes.new(sea_route_params)

      if @sea_route.save
        respond_to do |format|
          format.html { redirect_to chart_redirect_path, notice: "Rotta nautica creata." }
          format.json { render json: { status: "ok", sea_route_id: @sea_route.id, redirect_path: chart_redirect_path } }
        end
      else
        respond_to do |format|
          format.html { redirect_to chart_redirect_path, alert: @sea_route.errors.full_messages.to_sentence.presence || "Rotta non creata." }
          format.json { render json: { errors: @sea_route.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def cycle_direction
      @sea_route.toggle_bidirectional!

      render json: sea_route_payload(@sea_route)
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @sea_route.errors.full_messages }, status: :unprocessable_entity
    end

    def invert_direction
      @sea_route.invert_direction!

      render json: sea_route_payload(@sea_route)
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @sea_route.errors.full_messages }, status: :unprocessable_entity
    end

    def set_direction
      @sea_route.set_direction_state!(params[:direction_state])

      render json: sea_route_payload(@sea_route)
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @sea_route.errors.full_messages }, status: :unprocessable_entity
    end

    def update
      if @sea_route.update(sea_route_params)
        render json: sea_route_payload(@sea_route)
      else
        render json: { errors: @sea_route.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @sea_route.destroy!

      render json: { status: "ok" }
    end

    private
      def sea_route_params
        params.require(:sea_route).permit(:source_port_id, :target_port_id, :bidirectional, :position)
      end

      def set_sea_route
        @sea_route = Current.session.user.profile.sea_routes.find(params[:id])
      end

      def sea_route_payload(sea_route)
        {
          status: "ok",
          sea_route: {
            id: sea_route.id,
            source_port_id: sea_route.source_port_id,
            target_port_id: sea_route.target_port_id,
            source_port_name: sea_route.source_port.name,
            target_port_name: sea_route.target_port.name,
            bidirectional: sea_route.bidirectional,
            position: sea_route.position
          }
        }
      end

      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def chart_redirect_path
        return current_creator_carta_nautica_path(edit: 1) if current_chart_brand_port.blank?

        creator_brand_carta_nautica_path(brand_port_id: current_chart_brand_port.id, edit: 1)
      end

      def current_chart_brand_port
        return @current_chart_brand_port if defined?(@current_chart_brand_port)
        return @current_chart_brand_port = nil if params[:brand_port_id].blank?

        @current_chart_brand_port = Current.session.user.profile.ports.find_by(id: params[:brand_port_id], brand_root: true)
      end
  end
end
