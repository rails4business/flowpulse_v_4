class CreateStations < ActiveRecord::Migration[8.1]
  def change
    create_table :stations do |t|
      t.references :line, null: false, foreign_key: true
      t.references :experience, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :station_kind, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.integer :map_x
      t.integer :map_y
      t.text :description
      t.references :link_station, null: true, foreign_key: { to_table: :stations }
      t.references :link_port, null: true, foreign_key: { to_table: :ports }

      t.timestamps
    end

    add_index :stations, [:line_id, :slug], unique: true
    add_index :stations, [:line_id, :position]
  end
end
