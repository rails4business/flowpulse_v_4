class RemoveDescriptionFromLinesAndExperiences < ActiveRecord::Migration[8.1]
  def change
    remove_column :lines, :description, :text
    remove_column :experiences, :description, :text
  end
end
