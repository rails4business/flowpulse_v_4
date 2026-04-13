class RenameBrandDomainsToWebappDomains < ActiveRecord::Migration[8.1]
  def change
    rename_table :brand_domains, :webapp_domains if table_exists?(:brand_domains)

    rename_index_if_present :webapp_domains, :index_brand_domains_on_host, :index_webapp_domains_on_host
    rename_index_if_present :webapp_domains, :index_brand_domains_on_brand_port_id, :index_webapp_domains_on_brand_port_id
    rename_index_if_present :webapp_domains, :index_brand_domains_on_brand_port_id_and_locale, :index_webapp_domains_on_brand_port_id_and_locale
    rename_index_if_present :webapp_domains, :index_brand_domains_one_primary_per_brand, :index_webapp_domains_one_primary_per_brand
  end

  private
    def rename_index_if_present(table_name, old_name, new_name)
      return unless index_name_exists?(table_name, old_name)
      return if index_name_exists?(table_name, new_name)

      rename_index table_name, old_name, new_name
    end
end
