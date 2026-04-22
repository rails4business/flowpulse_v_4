module Creator
  class ContentsController < ApplicationController
    before_action :require_creator
    before_action :set_port
    before_action :set_content, only: %i[edit update]

    def new
      @content = @port.build_content(visibility: :draft)
    end

    def create
      @content = @port.build_content(content_params)

      if @content.save
        redirect_to creator_port_path(@port), notice: "Contenuto creato."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @content.update(content_params)
        redirect_to creator_port_path(@port), notice: "Contenuto aggiornato."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
      def require_creator
        redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
      end

      def set_port
        @port = Current.session.user.profile.ports.find(params[:port_id])
      end

      def set_content
        @content = @port.content or redirect_to(new_creator_port_content_path(@port))
      end

      def content_params
        params.require(:content).permit(
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
        )
      end
  end
end
