class CreateSeaRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :sea_routes do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :source_port, null: false, foreign_key: { to_table: :ports }
      t.references :target_port, null: false, foreign_key: { to_table: :ports }
      t.timestamps
    end

    add_index :sea_routes, [:profile_id, :source_port_id, :target_port_id], unique: true
  end
end
