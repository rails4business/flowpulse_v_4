require "set"

class CreatorController < ApplicationController
  before_action :require_creator

  def carta_nautica
    profile = Current.session.user.profile
    @brand_port = profile.ports.find_by(id: params[:brand_port_id], brand_root: true) if params[:brand_port_id].present?
    @brand_breadcrumbs = build_brand_breadcrumbs(profile, @brand_port)

    if @brand_port.present?
      @ports =
        profile.ports
          .where(brand_port_id: @brand_port.id)
          .where.not(id: @brand_port.id)
          .order(created_at: :desc)
      visible_port_ids = @ports.pluck(:id)
      @sea_routes =
        profile.sea_routes
          .includes(:source_port, :target_port)
          .where(source_port_id: visible_port_ids, target_port_id: visible_port_ids)
          .order(created_at: :desc)
    else
      @ports =
        profile.ports
          .where(brand_root: true)
          .where("brand_port_id IS NULL OR brand_port_id = ports.id")
          .order(created_at: :desc)
      visible_port_ids = @ports.pluck(:id)
      @sea_routes =
        profile.sea_routes
          .includes(:source_port, :target_port)
          .where(source_port_id: visible_port_ids, target_port_id: visible_port_ids)
          .order(created_at: :desc)
    end

    return unless params[:add_port].present? && params[:x].present? && params[:y].present?

    @port =
      if @brand_port.present?
        profile.ports.new(
          x: params[:x],
          y: params[:y],
          brand_port: @brand_port
        )
      else
        profile.ports.new(
          x: params[:x],
          y: params[:y],
          brand_root: true
        )
      end
  end

  def branch_map
  end

  def journey
  end

  def value_architecture
  end

  private

  helper_method :creator_chart_path_for

  def require_creator
    redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
  end

  def creator_chart_path_for(brand_port = nil, extra_params = {})
    params_hash = extra_params.compact
    return creator_carta_nautica_path(params_hash) if brand_port.blank?

    creator_brand_carta_nautica_path(brand_port_id: brand_port.id, **params_hash)
  end

  def build_brand_breadcrumbs(profile, brand_port)
    breadcrumbs = [
      {
        label: "Brands",
        path: creator_carta_nautica_path
      }
    ]

    return breadcrumbs if brand_port.blank?

    lineage = []
    current = brand_port
    visited_ids = Set.new

    while current.present?
      break if visited_ids.include?(current.id)

      visited_ids << current.id
      lineage << current
      break if current.brand_port_id.blank? || current.brand_port_id == current.id

      current = profile.ports.find_by(id: current.brand_port_id, brand_root: true)
    end

    lineage.reverse_each do |port|
      breadcrumbs << {
        label: port.name,
        path: creator_chart_path_for(port)
      }
    end

    breadcrumbs
  end
end
