class AddDirectionModeToSeaRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :sea_routes, :bidirectional, :boolean, null: false
    add_column :sea_routes, :position, :integer, null: false
  end
end
