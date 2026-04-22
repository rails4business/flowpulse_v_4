class CreateContents < ActiveRecord::Migration[8.1]
  def change
    create_table :contents do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :contentable, polymorphic: true, null: false
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.text :content
      t.text :mermaid
      t.string :banner_url
      t.string :thumb_url
      t.string :horizontal_cover_url
      t.string :vertical_cover_url
      t.string :url_media_content
      t.jsonb :meta, default: {}, null: false
      t.integer :visibility, default: 0, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :contents, [:profile_id, :slug], unique: true
    add_index :contents, [:contentable_type, :contentable_id], unique: true
    add_index :contents, :meta, using: :gin
  end
end
