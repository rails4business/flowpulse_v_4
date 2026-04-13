class RenameBrandPortIdToRootPortIdInWebappDomains < ActiveRecord::Migration[8.1]
  def change
    return unless table_exists?(:webapp_domains)
    return unless column_exists?(:webapp_domains, :root_port_id)

    rename_column :webapp_domains, :root_port_id, :brand_port_id

    rename_index_if_present :webapp_domains, :index_webapp_domains_on_root_port_id, :index_webapp_domains_on_brand_port_id
    rename_index_if_present :webapp_domains, :index_webapp_domains_on_root_port_id_and_locale, :index_webapp_domains_on_brand_port_id_and_locale
    rename_index_if_present :webapp_domains, :index_webapp_domains_one_primary_per_root, :index_webapp_domains_one_primary_per_brand
  end

  private
    def rename_index_if_present(table_name, old_name, new_name)
      return unless index_name_exists?(table_name, old_name)
      return if index_name_exists?(table_name, new_name)

      rename_index table_name, old_name, new_name
    end
end
