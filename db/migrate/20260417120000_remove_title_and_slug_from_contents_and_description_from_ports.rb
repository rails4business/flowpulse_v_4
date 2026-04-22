class RemoveTitleAndSlugFromContentsAndDescriptionFromPorts < ActiveRecord::Migration[8.1]
  def change
    remove_index :contents, column: [:profile_id, :slug]
    remove_column :contents, :title, :string
    remove_column :contents, :slug, :string
    remove_column :ports, :description, :text
  end
end
