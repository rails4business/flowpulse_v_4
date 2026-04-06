class AddSuperadminToUsersAndCreatorRequestedToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :superadmin, :boolean, null: false, default: false
    add_column :profiles, :creator_requested, :boolean, null: false, default: false
  end
end
