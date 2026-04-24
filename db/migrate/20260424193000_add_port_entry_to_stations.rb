class AddPortEntryToStations < ActiveRecord::Migration[8.0]
  def change
    add_column :stations, :port_entry, :boolean, default: false, null: false
  end
end
