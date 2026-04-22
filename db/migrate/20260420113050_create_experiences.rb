class CreateExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :experiences do |t|
      t.references :port, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :experience_kind, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.text :description

      t.timestamps
    end

    add_index :experiences, [:port_id, :slug], unique: true
    add_index :experiences, [:port_id, :position]
  end
end
