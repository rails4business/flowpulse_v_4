class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name, null: false
      t.string :slug, null: false
      t.text :bio
      t.string :visibility, null: false, default: "private"

      t.timestamps
    end

    add_index :profiles, :slug, unique: true
  end
end
