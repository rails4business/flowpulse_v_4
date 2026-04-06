class AddProfileModeToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :creator_enabled, :boolean, null: false, default: false
  end
end
