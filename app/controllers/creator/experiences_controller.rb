module Creator
  class ExperiencesController < ApplicationController
    before_action :require_creator
    before_action :set_port
    before_action :set_experience, only: %i[edit update destroy]

    def index
      @experiences = @port.experiences.includes(:stations, :parent_experience, :child_experiences)
    end

    def new
      @experience = @port.experiences.new(position: next_experience_position)
      load_parent_experiences
    end

    def create
      @experience = @port.experiences.new(experience_params)

      if @experience.save
        redirect_to creator_port_experiences_path(@port), notice: "Experience creata."
      else
        load_parent_experiences
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_parent_experiences
    end

    def update
      if @experience.update(experience_params)
        redirect_to creator_port_experiences_path(@port), notice: "Experience aggiornata."
      else
        load_parent_experiences
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @experience.destroy
      redirect_to creator_port_experiences_path(@port), notice: "Experience eliminata."
    end

    private
      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def set_port
        @port = Current.session.user.profile.ports.find(params[:port_id])
      end

      def set_experience
        @experience = @port.experiences.find(params[:id])
      end

      def experience_params
        params.require(:experience).permit(:name, :slug, :experience_kind, :position, :description, :parent_experience_id)
      end

      def next_experience_position
        (@port.experiences.maximum(:position) || -1) + 1
      end

      def load_parent_experiences
        @parent_experiences = @port.experiences.order(:position, :created_at)
        @parent_experiences = @parent_experiences.where.not(id: @experience.id) if @experience&.persisted?
      end
  end
end
