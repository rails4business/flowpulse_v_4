class CreatorController < ApplicationController
  before_action :require_creator

  def carta_nautica
    @ports = Current.session.user.profile.ports.order(created_at: :desc)
    @sea_routes = Current.session.user.profile.sea_routes.includes(:source_port, :target_port).order(created_at: :desc)
    return unless params[:add_port].present? && params[:x].present? && params[:y].present?

    @port = Current.session.user.profile.ports.new(
      x: params[:x],
      y: params[:y]
    )
  end

  def branch_map
  end

  def journey
  end

  def value_architecture
  end

  private

  def require_creator
    redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
  end
end
