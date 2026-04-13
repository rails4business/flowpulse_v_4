class Current < ActiveSupport::CurrentAttributes
  attribute :session, :webapp_domain, :resolved_domain_host, :domain_context_type
  delegate :user, to: :session, allow_nil: true
end
