class Certificate < ApplicationRecord
  belongs_to :lead
  belongs_to :datacontact
  belongs_to :enrollment
  belongs_to :service
  belongs_to :journey
  belongs_to :taxbranch
  belongs_to :domain_membership
  belongs_to :domain, optional: true

  belongs_to :issued_by_enrollment,
             class_name: "Enrollment",
             optional: true

  enum :status, {
    pending: 0,
    issued: 1,
    revoked: 2
  }, prefix: :status

  store_accessor :meta

  validates :role_name, presence: true

  def inferred_domain
    domain || domain_membership&.domain
  end
end
