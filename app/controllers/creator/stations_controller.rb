module Creator
  class StationsController < ApplicationController
    before_action :require_creator
    before_action :set_port
    before_action :set_line, except: :create_from_land_map
    before_action :set_station, only: %i[edit update destroy]

    def index
      @stations = @line.stations.includes(:link_station, :link_port)
    end

    def new
      @station = @line.stations.new(position: next_station_position)
      load_link_targets
    end

    def create
      @station = @line.stations.new(station_params_with_resolved_experience)

      if @station.save
        redirect_to creator_port_line_stations_path(@port, @line), notice: "Station creata."
      else
        load_link_targets
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_link_targets
    end

    def update
      if @station.update(station_params_with_resolved_experience)
        redirect_to creator_port_line_stations_path(@port, @line), notice: "Station aggiornata."
      else
        load_link_targets
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @station.destroy
      redirect_to creator_port_line_stations_path(@port, @line), notice: "Station eliminata."
    end

    def create_from_land_map
      @line = @port.lines.find(params.require(:station)[:line_id])
      station = @line.stations.new(land_map_station_params)
      station.position = (@line.stations.maximum(:position) || -1) + 1 if station.position.blank?
      station.experience = land_map_experience_for_station

      if station.save
        redirect_to land_map_creator_port_path(@port), notice: "Station creata dalla mappa."
      else
        redirect_to land_map_creator_port_path(@port), alert: station.errors.full_messages.to_sentence
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to land_map_creator_port_path(@port), alert: "Linea o experience non trovata."
    rescue ActiveRecord::RecordInvalid, ArgumentError => e
      message = e.respond_to?(:record) ? e.record.errors.full_messages.to_sentence : e.message
      redirect_to land_map_creator_port_path(@port), alert: message.presence || "Non sono riuscito a creare la station dalla mappa."
    end

    private
      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def set_port
        port_id = params[:port_id].presence || params[:id].presence
        @port = Current.session.user.profile.ports.find(port_id)
      end

      def set_line
        @line = @port.lines.find(params[:line_id])
      end

      def set_station
        @station = @line.stations.find(params[:id])
      end

      def station_params
        params.require(:station).permit(:experience_id, :name, :slug, :station_kind, :position, :map_x, :map_y, :description, :link_station_id, :link_port_id)
      end

      def land_map_station_params
        params.require(:station).permit(:name, :slug, :station_kind, :position, :map_x, :map_y, :description, :link_station_id, :link_port_id)
      end

      def next_station_position
        (@line.stations.maximum(:position) || -1) + 1
      end

      def load_link_targets
        @experiences = @port.experiences.order(:position, :created_at)
        @linkable_stations =
          Station.joins(:line)
            .where(lines: { port_id: @port.id })
            .where.not(line_id: @line.id)
            .order("lines.position ASC, stations.position ASC, stations.created_at ASC")
        @linkable_ports = Current.session.user.profile.ports.where.not(id: @port.id).order(:name)
      end

      def land_map_experience_for_station
        existing_id = params.dig(:station, :experience_id).presence
        return @port.experiences.find(existing_id) if existing_id.present?

        searched_name = params.dig(:station, :experience_search).to_s.strip
        if searched_name.present?
          matched_experience = find_experience_by_search(searched_name)
          return matched_experience if matched_experience.present?
        end

        new_name = params.dig(:station, :new_experience_name).to_s.strip
        raise ArgumentError, "Scegli una experience esistente oppure inserisci il nome di una nuova experience." if new_name.blank?

        @port.experiences.create!(
          name: new_name,
          slug: params.dig(:station, :new_experience_slug),
          experience_kind: params.dig(:station, :new_experience_kind).presence || "lesson",
          position: (@port.experiences.maximum(:position) || -1) + 1
        )
      end

      def station_params_with_resolved_experience
        permitted = station_params.to_h
        resolved_experience_id = resolve_experience_id_from_search
        permitted["experience_id"] = resolved_experience_id if resolved_experience_id.present?
        permitted
      end

      def resolve_experience_id_from_search
        existing_id = params.dig(:station, :experience_id).presence
        return existing_id if existing_id.present?

        searched_name = params.dig(:station, :experience_search).to_s.strip
        return if searched_name.blank?

        find_experience_by_search(searched_name)&.id
      end

      def find_experience_by_search(search)
        normalized = search.to_s.strip.downcase
        return if normalized.blank?

        @port.experiences.find_by("LOWER(name) = ?", normalized) ||
          @port.experiences.where("LOWER(name) LIKE ?", "#{normalized}%").order(:position, :created_at).first ||
          @port.experiences.where("LOWER(name) LIKE ?", "%#{normalized}%").order(:position, :created_at).first
      end
  end
end
