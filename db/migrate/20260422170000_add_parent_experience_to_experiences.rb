class AddParentExperienceToExperiences < ActiveRecord::Migration[8.0]
  def change
    add_reference :experiences, :parent_experience, foreign_key: { to_table: :experiences }
  end
end
