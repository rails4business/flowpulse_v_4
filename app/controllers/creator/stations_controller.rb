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
      @station = @line.stations.new(station_attributes_for_persistence)

      if save_station_with_group_controls(@station)
        redirect_to station_redirect_path(@station), notice: "Station creata."
      else
        load_link_targets
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_link_targets
    end

    def update
      if save_station_with_group_controls(@station)
        redirect_to station_redirect_path(@station), notice: "Station aggiornata."
      else
        load_link_targets
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @station.destroy
      redirect_to land_map_creator_port_path(@port, edit: 1), notice: "Station eliminata."
    end

    def create_from_land_map
      @line = @port.lines.find(params.require(:station)[:line_id])
      station = @line.stations.new(land_map_station_params)
      apply_land_map_shared_name!(station)
      apply_land_map_insertion!(station)
      station.experience = land_map_experience_for_station unless station.link_station_id.present?

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
        params.require(:station).permit(:experience_id, :name, :slug, :station_kind, :position, :map_x, :map_y, :description, :link_station_id, :link_port_id, :port_entry, :link_order, :shared_group_angle)
      end

      def land_map_station_params
        params.require(:station).permit(:name, :slug, :station_kind, :position, :map_x, :map_y, :description, :link_station_id, :link_port_id, :port_entry, :link_order)
      end

      def next_station_position
        (@line.stations.maximum(:position) || -1) + 1
      end

      def apply_land_map_insertion!(station)
        source_station = land_map_source_station

        if source_station.present?
          insert_station_before_or_after!(station, source_station)
          return
        end

        station.position = next_station_position if station.position.blank?
      end

      def apply_land_map_shared_name!(station)
        return if station.name.present?

        linked_station = linked_station_for_land_map
        return if linked_station.blank?

        station.name = "Collegamento a #{linked_station.primary_station.name}"
      end

      def insert_station_before_or_after!(station, source_station)
        if land_map_relative_position == "before"
          previous_station = previous_station_in_line(source_station)
          if previous_station.present?
            insert_station_between!(station, previous_station, source_station)
          else
            insert_station_free_before!(station, source_station)
          end
        else
          next_station = next_station_in_line(source_station)
          if next_station.present?
            insert_station_between!(station, source_station, next_station)
          else
            insert_station_free_after!(station, source_station)
          end
        end
      end

      def insert_station_free_before!(station, source_station)
        @line.stations.where("position >= ?", source_station.position).update_all("position = position + 1")
        station.position = source_station.position
      end

      def insert_station_free_after!(station, source_station)
        station.position = source_station.position + 1
      end

      def insert_station_between!(station, before_station, after_station)
        midpoint_x = midpoint(before_station.map_x, after_station.map_x)
        midpoint_y = midpoint(before_station.map_y, after_station.map_y)

        @line.stations.where("position >= ?", after_station.position).update_all("position = position + 1")

        station.position = before_station.position + 1
        station.map_x = midpoint_x if midpoint_x.present?
        station.map_y = midpoint_y if midpoint_y.present?
      end

      def midpoint(from, to)
        return if from.blank? || to.blank?

        ((from.to_i + to.to_i) / 2.0).round
      end

      def land_map_source_station
        return @land_map_source_station if defined?(@land_map_source_station)

        source_station_id = params.dig(:station, :source_station_id).presence
        @land_map_source_station =
          if source_station_id.present?
            @line.stations.find_by(id: source_station_id)
          end
      end

      def linked_station_for_land_map
        link_station_id = params.dig(:station, :link_station_id).presence
        return if link_station_id.blank?

        Station.joins(:line).where(lines: { port_id: @port.id }).find_by(id: link_station_id)&.primary_station
      end

      def next_station_in_line(station)
        @line.stations.where("position > ?", station.position).order(:position, :created_at).first
      end

      def previous_station_in_line(station)
        @line.stations.where("position < ?", station.position).order(position: :desc, created_at: :desc).first
      end

      def land_map_relative_position
        value = params.dig(:station, :relative_position).presence
        value.in?(%w[before after]) ? value : "after"
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
        resolved_port_id = resolve_port_id_from_search
        permitted["experience_id"] = resolved_experience_id if resolved_experience_id.present?
        permitted["link_port_id"] = resolved_port_id if resolved_port_id.present?
        permitted
      end

      def station_attributes_for_persistence
        attrs = station_params_with_resolved_experience
        @pending_shared_group_angle = attrs.delete("shared_group_angle")
        attrs
      end

      def save_station_with_group_controls(station)
        Station.transaction do
          station.assign_attributes(station_attributes_for_persistence)
          station.save!
          apply_shared_group_angle!(station)
        end

        true
      rescue ActiveRecord::RecordInvalid
        false
      end

      def apply_shared_group_angle!(station)
        return if @pending_shared_group_angle.blank?

        station.primary_station.update!(shared_group_angle: @pending_shared_group_angle)
      end

      def station_redirect_path(station)
        if params[:return_to] == "land_map"
          land_map_creator_port_path(@port, edit: 1, line_id: station.line_id, station_id: station.id)
        else
          creator_port_line_stations_path(@port, @line)
        end
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

      def resolve_port_id_from_search
        existing_id = params.dig(:station, :link_port_id).presence
        return existing_id if existing_id.present?

        searched_name = params.dig(:station, :link_port_search).to_s.strip
        return if searched_name.blank?

        find_port_by_search(searched_name)&.id
      end

      def find_port_by_search(search)
        normalized = search.to_s.strip.downcase
        return if normalized.blank?

        Current.session.user.profile.ports.where.not(id: @port.id).find_by("LOWER(name) = ?", normalized) ||
          Current.session.user.profile.ports.where.not(id: @port.id).where("LOWER(name) LIKE ?", "#{normalized}%").order(:name).first ||
          Current.session.user.profile.ports.where.not(id: @port.id).where("LOWER(name) LIKE ?", "%#{normalized}%").order(:name).first
      end
  end
end
