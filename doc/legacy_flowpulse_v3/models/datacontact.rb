class Datacontact < ApplicationRecord
  belongs_to :lead, optional: true
  belongs_to :referent_lead, class_name: "Lead", optional: true

  has_many :enrollments, dependent: :destroy
  has_many :journeys, through: :enrollments
  has_many :bookings,    dependent: :destroy
  has_many :payments,    dependent: :destroy
  has_many :mycontacts, dependent: :destroy
  has_many :certificates, dependent: :destroy

  has_many :requests_made,
           class_name: "Enrollment",
           foreign_key: :requested_by_lead_id

  has_many :invites_made,
           class_name: "Enrollment",
           foreign_key: :invited_by_lead_id

  def city
    self[:billing_city].to_s.presence
  end

  def city=(value)
    self[:billing_city] = value.to_s.strip.presence
  end

  def province
    datacontact_meta["province"].to_s.presence
  end

  def province=(value)
    normalized = value.to_s.strip.presence
    updated_meta = datacontact_meta

    if normalized.present?
      updated_meta["province"] = normalized
    else
      updated_meta.delete("province")
    end

    self.meta = updated_meta
  end

  def full_name
    [ first_name, last_name ].compact.join(" ").presence
  end

  def display_label
    full_name || email || phone || "Contatto"
  end

  def owned_by?(lead)
    lead.present? && lead_id == lead.id
  end

  def referent_is?(lead)
    lead.present? && referent_lead_id == lead.id
  end

  private

  def datacontact_meta
    meta.is_a?(Hash) ? meta.deep_dup : {}
  end
end
