class AddColorToLines < ActiveRecord::Migration[8.1]
  def change
    add_column :lines, :color, :string
  end
end
