json.extract! payment, :id, :contact_id, :payable_id, :payable_type, :method, :status, :amount_euro, :amount_dash, :currency, :external_id, :paid_at, :kind, :refund_amount_euro, :refund_due_at, :parent_payment_id, :notes, :meta, :created_at, :updated_at
json.url payment_url(payment, format: :json)
