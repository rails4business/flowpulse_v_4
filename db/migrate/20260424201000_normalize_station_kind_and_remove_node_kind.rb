class NormalizeStationKindAndRemoveNodeKind < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE stations
      SET station_kind = CASE station_kind
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        ELSE 0
      END
    SQL

    remove_column :stations, :node_kind if column_exists?(:stations, :node_kind)
  end

  def down
    add_column :stations, :node_kind, :integer, default: 0, null: false unless column_exists?(:stations, :node_kind)
  end
end
