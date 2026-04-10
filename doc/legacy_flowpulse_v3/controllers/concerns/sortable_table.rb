# app/controllers/concerns/sortable_table.rb
module SortableTable
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
  end

  private

  def sort_column
    params[:sort].presence_in(permitted_sort_columns) || default_sort_column
  end

  def sort_direction
    params[:direction].presence_in(%w[asc desc]) || "desc"
  end

  # Override nei controller che includono
  def permitted_sort_columns
    []
  end

  def default_sort_column
    "created_at"
  end
end
