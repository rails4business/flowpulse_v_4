class AddMapCoordinatesToStations < ActiveRecord::Migration[8.1]
  def change
    add_column :stations, :map_x, :integer unless column_exists?(:stations, :map_x)
    add_column :stations, :map_y, :integer unless column_exists?(:stations, :map_y)
  end
end
