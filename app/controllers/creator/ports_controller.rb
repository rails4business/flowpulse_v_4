module Creator
  class PortsController < ApplicationController
    before_action :require_creator
    before_action :set_port, only: %i[ edit update destroy ]

    def new
      @port = Current.session.user.profile.ports.new(x: params[:x], y: params[:y])
    end

    def edit
    end

    def create
      @port = Current.session.user.profile.ports.new(port_params)

      if @port.save
        redirect_to creator_carta_nautica_path, notice: "Porto creato con successo sulla tua carta nautica."
      else
        @ports = Current.session.user.profile.ports.order(created_at: :desc)
        render "creator/carta_nautica", status: :unprocessable_entity
      end
    end

    def update
      if @port.update(port_params)
        respond_to do |format|
          format.html { redirect_to creator_carta_nautica_path, notice: "Il porto è stato aggiornato." }
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
      redirect_to creator_carta_nautica_path, notice: "Porto rimosso definitivamente."
    end

    private
      def set_port
        @port = Current.session.user.profile.ports.find(params[:id])
      end

      def port_params
        params.require(:port).permit(:name, :slug, :port_kind, :visibility, :description, :brand_port_id, :color_key, :x, :y)
      end

      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end
  end
end
