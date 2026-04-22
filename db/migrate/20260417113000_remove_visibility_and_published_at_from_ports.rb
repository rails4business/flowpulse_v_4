class RemoveVisibilityAndPublishedAtFromPorts < ActiveRecord::Migration[8.1]
  def change
    remove_column :ports, :visibility, :integer
    remove_column :ports, :published_at, :datetime
  end
end
