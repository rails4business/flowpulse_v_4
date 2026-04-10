class Eventdate < ApplicationRecord
  # Può essere usato come:
  # - evento di calendario (solo date + location + journey opzionale)
  # - log/diario (taxbranch + lead + cycle + status)

  # 🔗 Relazioni
  #
  belongs_to :child_journey, class_name: "Journey", optional: true
  belongs_to :journey,   optional: true
  belongs_to :taxbranch, optional: true
  belongs_to :lead,      optional: true
  belongs_to :parent_eventdate, class_name: "Eventdate", optional: true
  has_many   :child_eventdates,
             class_name: "Eventdate",
             foreign_key: :parent_eventdate_id,
             dependent: :nullify

  has_many :commitments,    dependent: :destroy
  has_many :bookings, dependent: :destroy

  acts_as_list scope: :journey

  # 🎭 Tipologia / meta-evento
  enum :event_type, { check: 0,  event: 1, prenotation: 2, message: 3, comment: 4, note: 5, taxbranch_scheduled: 6 }
  # ✅ Stati del "diario"
  enum :status, { pending: 0, tracking: 1, completed: 2, skipped: 3, archived: 4 }
  enum :kind_event, { session: 0, meeting: 1, online_call: 2, focus: 3, recovery: 4   }
  enum :unit_duration, { minutes: 0, hours: 1, days: 2 }

  enum :mode,       { onsite: 0, online: 1, hybrid: 2 }
  enum :visibility, { internal_date: 0, public_date: 1 }




  # 📅 Validazione "da calendario" – sempre sensata
  validates :description, presence: true
  validates :lead, presence: true

  # 📓 Validazioni "da diario" – SOLO se stai usando taxbranch
  with_options if: -> { taxbranch_id.present? } do
    # validates :cycle, presence: true, numericality: { greater_than_or_equal_to: 1 }
    validates :status, presence: true
  end

  before_validation :apply_duration_to_end_at
  before_validation :ensure_meta_hash
  before_validation :apply_defaults

  # Questionnaire helpers
  def questionnaire_submission?
    questionnaire_taxbranch_id.present?
  end

  def questionnaire_taxbranch_id
    raw = (meta || {})["questionnaire_taxbranch_id"]
    raw.present? ? raw.to_i : nil
  end

  def questionnaire_taxbranch_id=(value)
    self.meta = (meta || {}).merge("questionnaire_taxbranch_id" => value.presence)
  end

  def questionnaire_answers
    raw = (meta || {})["answers"]
    raw.is_a?(Array) ? raw : []
  end

  # Accepts:
  # - Array: [{ question_taxbranch_id: 1, value: "..." }, ...]
  # - Hash: { "1" => "value", "2" => { value: "x", kind: "open_text" } }
  def questionnaire_answers=(value)
    normalized =
      case value
      when Array
        value.filter_map do |entry|
          next unless entry.respond_to?(:to_h)

          item = entry.to_h.stringify_keys
          qid = item["question_taxbranch_id"].presence || item["question_id"].presence
          next if qid.blank?

          {
            "question_taxbranch_id" => qid.to_i,
            "kind" => item["kind"].presence || "open_text",
            "value" => item["value"]
          }
        end
      when Hash
        value.filter_map do |question_id, payload|
          if payload.is_a?(Hash)
            {
              "question_taxbranch_id" => question_id.to_i,
              "kind" => payload[:kind].presence || payload["kind"].presence || "open_text",
              "value" => payload[:value].presence || payload["value"]
            }
          else
            {
              "question_taxbranch_id" => question_id.to_i,
              "kind" => "open_text",
              "value" => payload
            }
          end
        end
      else
        []
      end

    self.meta = (meta || {}).merge("answers" => normalized)
  end

  def answer_for(question_taxbranch_id)
    questionnaire_answers.find { |answer| answer["question_taxbranch_id"].to_i == question_taxbranch_id.to_i }
  end

  def questionnaire_score_result
    result = (meta || {})["score_result"]
    result.is_a?(Hash) ? result : {}
  end

  private

  def apply_duration_to_end_at
    return if date_end.present?
    return if date_start.blank? || time_duration.blank? || unit_duration.blank?

    multiplier =
      case unit_duration
      when "minutes" then 1.minute
      when "hours" then 1.hour
      when "days" then 1.day
      else
        nil
      end
    return unless multiplier

    self.date_end = date_start + time_duration.to_i * multiplier
  end

  def ensure_meta_hash
    self.meta = {} unless meta.is_a?(Hash)
  end

  def apply_defaults
    self.status ||= "pending"
  end
end
