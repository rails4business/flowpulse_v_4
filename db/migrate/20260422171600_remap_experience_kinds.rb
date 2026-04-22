class RemapExperienceKinds < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE experiences
      SET experience_kind = CASE experience_kind
        WHEN 0 THEN 0
        WHEN 1 THEN 2
        WHEN 2 THEN 6
        WHEN 3 THEN 7
        WHEN 4 THEN 8
        WHEN 5 THEN 9
        ELSE experience_kind
      END
    SQL
  end

  def down
    execute <<~SQL
      UPDATE experiences
      SET experience_kind = CASE experience_kind
        WHEN 0 THEN 0
        WHEN 2 THEN 1
        WHEN 6 THEN 2
        WHEN 7 THEN 3
        WHEN 8 THEN 4
        WHEN 9 THEN 5
        ELSE experience_kind
      END
    SQL
  end
end
