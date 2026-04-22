require "set"

class CreatorController < ApplicationController
  before_action :require_creator
  helper_method :creator_chart_path_for, :brand_tree_children_for

  def carta_nautica
    profile = Current.session.user.profile
    @can_create_brand_root = Current.session.user.superadmin? || !profile.ports.where(brand_root: true).exists?
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
        return if !@can_create_brand_root

        profile.ports.new(
          x: params[:x],
          y: params[:y],
          brand_root: true
        )
      end
  end

  def branch_map
  end

  def brand_tree
    profile = Current.session.user.profile
    @brand_tree_scope = params[:scope].presence_in(%w[all subtree]) || default_brand_tree_scope
    @brand_tree_depth = params[:tree_depth].presence_in(%w[all children]) || "all"
    @brand_tree_root =
      if @brand_tree_scope == "subtree" && params[:root_brand_id].present?
        profile.ports.find_by(id: params[:root_brand_id], brand_root: true)
      end

    @root_brand_ports =
      if @brand_tree_scope == "subtree" && @brand_tree_root.present?
        [@brand_tree_root]
      else
        profile.ports
          .where(brand_root: true)
          .where("brand_port_id IS NULL OR brand_port_id = ports.id")
          .order(created_at: :asc)
      end
  end

  def journey
  end

  def value_architecture
  end

  private

  def require_creator
    redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
  end

  def creator_chart_path_for(brand_port = nil, extra_params = {})
    params_hash = extra_params.compact
    return current_creator_carta_nautica_path(params_hash) if brand_port.blank?

    creator_brand_carta_nautica_path(brand_port_id: brand_port.id, **params_hash)
  end

  def build_brand_breadcrumbs(profile, brand_port)
    breadcrumbs = [
      {
        label: "Brands",
        path: current_creator_carta_nautica_path
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

  def brand_tree_children_for(parent_port)
    if @brand_tree_scope == "subtree" && @brand_tree_depth == "children" && @brand_tree_root.present? && parent_port.id != @brand_tree_root.id
      return Current.session.user.profile.ports.none
    end

    children = Current.session.user.profile
      .ports
      .where(brand_root: true, brand_port_id: parent_port.id)
      .where.not(id: parent_port.id)
      .order(created_at: :asc)

    children
  end

  def default_brand_tree_scope
    webapp_domain_context? && current_webapp_domain&.brand_port_id.present? ? "subtree" : "all"
  end
end
