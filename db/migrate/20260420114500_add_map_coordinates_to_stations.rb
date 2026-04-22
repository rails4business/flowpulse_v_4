class AddMapCoordinatesToStations < ActiveRecord::Migration[8.1]
  def change
    add_column :stations, :map_x, :integer
    add_column :stations, :map_y, :integer
  end
end
