class DomainMembership < ApplicationRecord
  belongs_to :lead
  belongs_to :domain
  has_many :certificates, dependent: :nullify

  enum :status, { active: 0, inactive: 1 }, default: :active

  validates :domain_active_role, presence: true
  validates :lead_id, uniqueness: { scope: :domain_id }

  scope :primary_membership, -> { where(primary: true) }
  scope :active_membership, -> { active }
end
