module Creator
  class LinesController < ApplicationController
    before_action :require_creator
    before_action :set_port
    before_action :set_line, only: %i[edit update destroy]

    def index
      @lines = @port.lines.includes(:stations)
    end

    def new
      @line = @port.lines.new(position: next_line_position)
    end

    def create
      return create_from_land_map if params.dig(:line, :source) == "land_map"

      @line = @port.lines.new(line_params)

      if @line.save
        redirect_to creator_port_lines_path(@port), notice: "Linea creata."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @line.update(line_params)
        redirect_to creator_port_lines_path(@port), notice: "Linea aggiornata."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @line.destroy
      redirect_to creator_port_lines_path(@port), notice: "Linea eliminata."
    end

    private
      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def set_port
        @port = Current.session.user.profile.ports.find(params[:port_id])
      end

      def set_line
        @line = @port.lines.find(params[:id])
      end

      def line_params
        params.require(:line).permit(:name, :slug, :line_kind, :position, :color, :description)
      end

      def next_line_position
        (@port.lines.maximum(:position) || -1) + 1
      end

      def create_from_land_map
        ActiveRecord::Base.transaction do
          @line = @port.lines.new(line_params)
          @line.save!

          @line.stations.create!(initial_station_attributes)
        end

        redirect_to land_map_creator_port_path(@port), notice: "Linea e prima station create dalla mappa."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to land_map_creator_port_path(@port), alert: e.record.errors.full_messages.to_sentence.presence || "Non sono riuscito a creare la linea dalla mappa."
      rescue ArgumentError => e
        redirect_to land_map_creator_port_path(@port), alert: e.message
      end

      def initial_station_attributes
        attrs = {
            name: initial_station_name,
            slug: initial_station_slug.presence,
            station_kind: initial_station_kind,
            position: 0,
            map_x: initial_station_map_x,
            map_y: initial_station_map_y
          }

        if source_station.present?
          attrs[:link_station] = source_station
        else
          experience = line_land_map_experience
          raise ActiveRecord::RecordInvalid, experience if experience.invalid?

          attrs[:experience] = experience
        end

        attrs
      end

      def line_land_map_experience
        existing_id = params.dig(:line, :initial_experience_id).presence
        return @port.experiences.find(existing_id) if existing_id.present?

        new_name = params.dig(:line, :new_experience_name).to_s.strip
        return build_default_experience if new_name.blank?

        @port.experiences.create(
          name: new_name,
          slug: params.dig(:line, :new_experience_slug),
          experience_kind: params.dig(:line, :new_experience_kind).presence || "lesson",
          position: (@port.experiences.maximum(:position) || -1) + 1
        )
      end

      def build_default_experience
        base_name = initial_station_name.presence || @line.name.presence || "Inizio"
        position = (@port.experiences.maximum(:position) || -1) + 1

        @port.experiences.create(
          name: "Experience #{base_name}",
          slug: "experience-#{base_name.to_s.parameterize}-#{position + 1}",
          experience_kind: "lesson",
          position: position
        )
      end

      def initial_station_name
        return params.dig(:line, :initial_station_name).presence if params.dig(:line, :initial_station_name).present?
        return "Collegamento a #{source_station.name}" if source_station.present?

        "Inizio"
      end

      def initial_station_slug
        params.dig(:line, :initial_station_slug)
      end

      def initial_station_kind
        params.dig(:line, :initial_station_kind).presence || "normal"
      end

      def initial_station_map_x
        params.dig(:line, :initial_station_map_x).presence
      end

      def initial_station_map_y
        params.dig(:line, :initial_station_map_y).presence
      end

      def source_station
        return @source_station if defined?(@source_station)

        station_id = params.dig(:line, :source_station_id).presence
        @source_station =
          if station_id.present?
            Station.joins(:line).where(lines: { port_id: @port.id }).find_by(id: station_id)&.primary_station
          end
      end
  end
end
