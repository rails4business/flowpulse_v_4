json.extract! enrollment, :id, :service_id, :journey_id, :contact_id, :role_name,
                        :participant_role, :target_role, :status, :mode,
                        :request_kind, :requested_by_lead_id, :invited_by_lead_id,
                        :price_euro, :price_dash, :notes, :meta, :certified_at,
                        :created_at, :updated_at
json.url enrollment_url(enrollment, format: :json)
