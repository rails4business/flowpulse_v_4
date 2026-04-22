class AddWebappSeaChartToPorts < ActiveRecord::Migration[8.1]
  def change
    add_column :ports, :webapp_sea_chart, :jsonb, default: {}, null: false
    add_index :ports, :webapp_sea_chart, using: :gin
  end
end
