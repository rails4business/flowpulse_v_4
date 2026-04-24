class AddNodeKindToStations < ActiveRecord::Migration[8.0]
  def up
    add_column :stations, :node_kind, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE stations
      SET node_kind = CASE station_kind
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        ELSE 0
      END
    SQL
  end

  def down
    remove_column :stations, :node_kind
  end
end
