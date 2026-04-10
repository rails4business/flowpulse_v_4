class Commitment < ApplicationRecord
  belongs_to :taxbranch, optional: true
  belongs_to :eventdate, optional: true

  has_many :bookings

  enum :commitment_kind, {
    internal_task: 0,
    operator_role: 1,
    client_commitment: 2,
    event_session: 3
  }

  validate :eventdate_or_journey_presence

  delegate :journey, to: :eventdate, allow_nil: true

  acts_as_list scope: :eventdate_id
  scope :ordered, -> { order(:position) }

  private

  def eventdate_or_journey_presence
    return if eventdate.present?
    return if direct_journey_reference?

    errors.add(:base, "Collega il commitment a un evento o a un journey.")
  end

  def direct_journey_reference?
    has_attribute?(:journey_id) && self[:journey_id].present?
  end
end
