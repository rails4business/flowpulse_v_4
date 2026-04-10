json.extract! lead, :id, :name, :surname, :username, :email, :phone, :token, :user_id, :parent_id, :referral_lead_id, :meta, :created_at, :updated_at
json.url lead_url(lead, format: :json)
