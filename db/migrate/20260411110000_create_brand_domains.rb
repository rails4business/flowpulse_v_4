class CreateBrandDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :brand_domains do |t|
      t.references :brand_port, null: false, foreign_key: { to_table: :ports }
      t.string :host, null: false
      t.string :locale, null: false, default: "it"
      t.boolean :primary, null: false, default: false
      t.boolean :published, null: false, default: false
      t.string :title
      t.string :seo_title
      t.text :seo_description
      t.string :favicon_url
      t.string :square_logo_url
      t.string :horizontal_logo_url
      t.string :header_bg_color
      t.string :header_text_color
      t.string :accent_color
      t.string :background_color

      t.string :home_page_key
      t.text :custom_css
      t.timestamps
    end

    add_index :brand_domains, :host, unique: true
    add_index :brand_domains, [ :brand_port_id, :locale ], unique: true
    add_index :brand_domains, [ :brand_port_id, :primary ], unique: true, where: "\"primary\" = true", name: "index_brand_domains_one_primary_per_brand"
  end
end
