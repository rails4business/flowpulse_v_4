class CreatePorts < ActiveRecord::Migration[8.1]
  def change
    create_table :ports do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :brand_port, foreign_key: { to_table: :ports }
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :port_kind, default: 0, null: false
      t.string :color_key
      t.integer :visibility, default: 0, null: false
      t.text :description
      t.integer :x
      t.integer :y
      t.jsonb :meta, default: {}
      t.datetime :published_at


      t.timestamps
    end
    add_index :ports, [ :profile_id, :slug ], unique: true
  end
end
