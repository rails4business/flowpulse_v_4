class AddEntryValueAndBrandRootToPorts < ActiveRecord::Migration[8.1]
  def change
    add_column :ports, :entry_value, :string
    add_column :ports, :brand_root, :boolean, null: false, default: false
    add_index :ports, :brand_root
  end
end
