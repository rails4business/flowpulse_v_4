class Activity < ApplicationRecord
  encrypts :location_address
  belongs_to :lead
  belongs_to :domain, optional: true
  belongs_to :taxbranch, optional: true
  belongs_to :service, optional: true
  belongs_to :booking, optional: true
  belongs_to :enrollment, optional: true
  belongs_to :eventdate, optional: true
  belongs_to :certificate, optional: true

  enum :kind, {
    questionnaire_submission: "questionnaire_submission",
    step_completed: "step_completed",
    note: "note"
  }, prefix: true

  enum :status, {
    recorded: "recorded",
    reviewed: "reviewed",
    archived: "archived"
  }, prefix: true

  validates :kind, :status, :occurred_at, presence: true

  scope :recent_first, -> { order(occurred_at: :desc, id: :desc) }
  scope :questionnaires, -> { where(kind: kinds[:questionnaire_submission]) }
end
