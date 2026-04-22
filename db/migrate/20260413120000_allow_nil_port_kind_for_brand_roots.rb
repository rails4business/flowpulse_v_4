class AllowNilPortKindForBrandRoots < ActiveRecord::Migration[8.1]
  def up
    change_column_default :ports, :port_kind, from: 0, to: nil
    change_column_null :ports, :port_kind, true

    execute <<~SQL.squish
      UPDATE ports
      SET port_kind = NULL
      WHERE brand_root = TRUE
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE ports
      SET port_kind = 0
      WHERE port_kind IS NULL
    SQL

    change_column_null :ports, :port_kind, false
    change_column_default :ports, :port_kind, from: nil, to: 0
  end
end
