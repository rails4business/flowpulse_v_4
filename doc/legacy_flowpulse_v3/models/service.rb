require "securerandom"

class Service < ApplicationRecord
  belongs_to :taxbranch, optional: true
  belongs_to :lead, optional: true

  has_many :journeys, dependent: :nullify
  has_many :eventdates, through: :journeys
  has_many :enrollments, dependent: :nullify
  has_many :bookings, dependent: :nullify
  has_many :certificates, dependent: :restrict_with_exception

  # Subway Map Associations
  # Next stops (Outgoing)
  has_many :outgoing_journeys, through: :taxbranch, source: :journeys
  has_many :destination_taxbranches, through: :outgoing_journeys, source: :end_taxbranch
  has_many :next_services, through: :destination_taxbranches, source: :service

  # Previous stops (Incoming)
  has_many :incoming_journeys, through: :taxbranch, source: :incoming_journeys
  has_many :origin_taxbranches, through: :incoming_journeys, source: :taxbranch
  has_many :previous_services, through: :origin_taxbranches, source: :service

  store_accessor :meta, :tags, :category

  validates :slug, presence: true, uniqueness: true
  validate :role_lists_must_belong_to_domain_roles

  before_validation :ensure_slug!
  before_save :ensure_taxbranch_category

  PHASES = {
    problema: 0,
    obiettivo: 1,
    previsione: 2,
    responsabile_progettazione: 3,
    step_necessari: 4,
    impegno: 5,
    realizzazione: 6,
    test: 7,
    attivo: 8,
    chiuso: 9
  }.freeze

  enum :enrollable_from_phase, PHASES, prefix: true
  enum :enrollable_until_phase, PHASES, prefix: true

  def allowed_roles=(value)
    self[:allowed_roles] = normalize_role_list(value)
  end

  def output_roles=(value)
    self[:output_roles] = normalize_role_list(value)
  end

  def allowed_roles_text
    Array(allowed_roles).join("\n")
  end

  def output_roles_text
    Array(output_roles).join("\n")
  end

  def verifier_roles=(value)
    self[:verifier_roles] = normalize_role_list(value)
  end

  def verifier_roles_text
    Array(verifier_roles).join("\n")
  end

  def builders_roles=(value)
    self[:builders_roles] = normalize_role_list(value)
  end

  def drivers_roles=(value)
    self[:drivers_roles] = normalize_role_list(value)
  end

  def builders_roles_text
    Array(builders_roles).join("\n")
  end

  def drivers_roles_text
    Array(drivers_roles).join("\n")
  end

  def journey_function_active
    journeys
      .select(&:journey_function?)
      .reject { |journey| journey.kind == "cycle_template" }
      .select { |journey| journey.end_at.blank? }
      .max_by { |journey| journey.start_at || journey.created_at }
  end



  def journey_function_active_template
    journeys
      .select(&:journey_function?)
      .select { |journey| journey.kind == "cycle_template" }
      .select { |journey| journey.end_at.blank? }
      .max_by { |journey| journey.start_at || journey.created_at }
  end

  private

  def ensure_slug!
    return if slug.present?

    base = (name.presence || "service-#{SecureRandom.hex(3)}").parameterize
    self.slug = base.presence || "service-#{SecureRandom.hex(3)}"
  end

  def ensure_taxbranch_category
    return unless taxbranch
    return if taxbranch.slug_category == "service"

    taxbranch.update(slug_category: "service")
  end

  def normalize_role_list(value)
    list =
      case value
      when String
        value.split(/[\n,;]/)
      when Array
        value
      else
        Array(value)
      end

    list.filter_map { |entry| entry.to_s.strip.presence }.uniq
  end

  def role_lists_must_belong_to_domain_roles
    lists = {
      allowed_roles: allowed_roles,
      output_roles: output_roles,
      builders_roles: builders_roles,
      drivers_roles: drivers_roles,
      verifier_roles: verifier_roles
    }

    return if lists.values.all?(&:blank?)

    available = Array(taxbranch&.header_domain&.operative_roles).filter_map { |role| role.to_s.strip.presence }.uniq
    if available.blank?
      errors.add(:base, "Il dominio del service non ha ruoli operativi disponibili.")
      return
    end

    lists.each do |field, values|
      invalid = Array(values).filter_map { |v| v.to_s.strip.presence }.uniq - available
      next if invalid.blank?

      errors.add(field, "contiene ruoli non presenti nel dominio: #{invalid.join(', ')}")
    end
  end
end
