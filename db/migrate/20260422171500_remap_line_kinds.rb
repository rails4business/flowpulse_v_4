class RemapLineKinds < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE lines
      SET line_kind = CASE line_kind
        WHEN 0 THEN 3
        WHEN 1 THEN 3
        WHEN 2 THEN 2
        WHEN 3 THEN 0
        ELSE line_kind
      END
    SQL
  end

  def down
    execute <<~SQL
      UPDATE lines
      SET line_kind = CASE line_kind
        WHEN 0 THEN 3
        WHEN 2 THEN 2
        WHEN 3 THEN 0
        ELSE line_kind
      END
    SQL
  end
end
