class RemoveProfileIdFromContents < ActiveRecord::Migration[8.1]
  def change
    remove_reference :contents, :profile, foreign_key: true
  end
end
