class Mycontact < ApplicationRecord
  belongs_to :lead
  belongs_to :datacontact

  STATUSES = %w[pending approved rejected].freeze

  validates :status_contact, inclusion: { in: STATUSES }, allow_nil: true

  def approved?
    status_contact == "approved"
  end

  def pending?
    status_contact == "pending"
  end

  def rejected?
    status_contact == "rejected"
  end
end
