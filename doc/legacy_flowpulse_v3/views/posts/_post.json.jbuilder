json.extract! post, :id, :lead_id, :title, :slug, :description, :thumb_url, :horizontal_cover_url, :vertical_cover_url, :banner_url, :content, :published_at, :taxbranch_id, :status, :meta, :created_at, :updated_at
json.url post_url(post, format: :json)
