class AddSharedGroupControlsToStations < ActiveRecord::Migration[8.0]
  def change
    add_column :stations, :link_order, :integer, null: false, default: 0
    add_column :stations, :shared_group_angle, :integer, null: false, default: 0
  end
end
