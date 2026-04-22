module Creator
  class PortsController < ApplicationController
    before_action :require_creator
    before_action :set_port, only: %i[ show edit update destroy preview land_map ]
    before_action :prevent_extra_brand_root_for_creator, only: %i[new create]
    layout "brand_public", only: :preview

    LAND_MAP_PALETTE = %w[#2563eb #16a34a #dc2626 #d97706 #7c3aed #0891b2].freeze

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
      @port.build_content(visibility: :draft) if @port.content.blank?
    end

    def show
    end

    def preview
      unless @port.web_app?
        return redirect_to creator_port_path(@port), alert: "L'anteprima è disponibile solo per i port di tipo web app."
      end

      @brand_port = @port.inherited_brand_port || @port
      @webapp_domain =
        @port.webapp_domains.order(primary: :desc, locale: :asc).first
      @webapp_domains = @brand_port.webapp_domains.where(published: true).order(primary: :desc, locale: :asc)
      @brand_nav_routes =
        @brand_port.outgoing_sea_routes
          .includes(target_port: :content)
          .ordered
          .select { |route| route.target_port.content.present? }

      render :preview
    end

    def land_map
      @lines = @port.lines.includes(stations: [:experience, :link_station, :link_port])
      @experiences = @port.experiences.order(:position, :created_at)
      @edit_mode = ActiveModel::Type::Boolean.new.cast(params[:edit])
      @active_panel = params[:panel].presence_in(%w[new_line new_station edit_line edit_station])
      @selected_station = find_selected_station
      @selected_line = @selected_station&.line || (@port.lines.find_by(id: params[:line_id]) if params[:line_id].present?)
      load_land_map_link_targets if @selected_line.present?
      @line_map_rows = build_line_map_rows
      @map_width = [1200, station_count_max * 180 + 240].max
      @map_height = [720, @line_map_rows.size * 150 + 180].max
      @station_positions = build_station_positions
      @link_segments = build_link_segments
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
        params.require(:port).permit(
          :name,
          :slug,
          :port_kind,
          :entry_value,
          :webapp_sea_chart_yaml,
          :brand_root,
          :brand_port_id,
          :color_key,
          :x,
          :y,
          content_attributes: [
            :id,
            :subtitle,
            :description,
            :content,
            :mermaid,
            :banner_url,
            :thumb_url,
            :horizontal_cover_url,
            :vertical_cover_url,
            :url_media_content,
            :visibility,
            :published_at
          ]
        )
      end

      def route_source_port_from_params
        return if params[:route_source_port_id].blank?

        Current.session.user.profile.ports.find_by(id: params[:route_source_port_id])
      end

      def prevent_extra_brand_root_for_creator
        return if Current.session.user.superadmin?
        return unless brand_root_request?
        return unless Current.session.user.profile.ports.where(brand_root: true).exists?

        redirect_to current_creator_carta_nautica_path(edit: 1), alert: "Per ora un creator puo' gestire un solo brand root."
      end

      def brand_root_request?
        ActiveModel::Type::Boolean.new.cast(params[:brand_root]) ||
          ActiveModel::Type::Boolean.new.cast(params.dig(:port, :brand_root))
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
        return current_creator_carta_nautica_path(edit: 1) if brand_port.blank? || brand_port == port

        creator_brand_carta_nautica_path(brand_port_id: brand_port.id, edit: 1)
      end

      def build_line_map_rows
        @lines.each_with_index.map do |line, index|
          {
            line: line,
            color: line.color.presence || LAND_MAP_PALETTE[index % LAND_MAP_PALETTE.length],
            y: 140 + (index * 140)
          }
        end
      end

      def station_count_max
        [@lines.map { |line| line.stations.size }.max.to_i, 4].max
      end

      def build_station_positions
        positions = {}

        @line_map_rows.each do |row|
          row[:line].stations.each_with_index do |station, index|
            x = station.map_x.presence || 140 + (index * 180)
            y = station.map_y.presence || row[:y]
            positions[station.id] = {
              x: x,
              y: y,
              color: row[:color]
            }
          end
        end

        positions
      end

      def build_link_segments
        @lines.flat_map do |line|
          line.stations.filter_map do |station|
            next if station.link_station.blank?

            from = @station_positions[station.id]
            to = @station_positions[station.link_station_id]
            next if from.blank? || to.blank?

            {
              from: from,
              to: to,
              station: station,
              selected: @selected_station.present? && [station.id, station.link_station_id].include?(@selected_station.id)
            }
          end
        end
      end

      def find_selected_station
        return if params[:station_id].blank?

        Station.joins(:line).where(lines: { port_id: @port.id }).find_by(id: params[:station_id])
      end

      def load_land_map_link_targets
        @linkable_stations =
          Station.joins(:line)
            .where(lines: { port_id: @port.id })
            .where.not(line_id: @selected_line.id)
            .order("lines.position ASC, stations.position ASC, stations.created_at ASC")
        @linkable_ports = Current.session.user.profile.ports.where.not(id: @port.id).order(:name)
      end
  end
end
