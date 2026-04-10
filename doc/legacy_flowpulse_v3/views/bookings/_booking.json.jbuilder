json.extract! booking, :id, :service_id, :eventdate_id, :contact_id, :enrollment_id, :commitment_id, :status, :mode, :participant_role, :requested_by_lead_id, :invited_by_lead_id, :price_euro, :price_dash, :notes, :meta, :created_at, :updated_at
json.url booking_url(booking, format: :json)
