json.extract! domain, :id, :host, :language, :title, :description, :favicon_url, :square_logo_url, :horizontal_logo_url, :provider, :taxbranch_id, :created_at, :updated_at
json.url domain_url(domain, format: :json)
