class ReplaceCreatorBooleanWithUntilAndAddProfessionalAccessToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :creator_enabled_until, :datetime
    add_column :profiles, :professional_requested, :boolean, null: false, default: false
    add_column :profiles, :professional_enabled_until, :datetime

    remove_column :profiles, :creator_enabled, :boolean, default: false, null: false
  end
end
