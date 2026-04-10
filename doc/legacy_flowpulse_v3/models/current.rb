# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :domain, :taxbranch
  delegate :user, to: :session, allow_nil: true
end
