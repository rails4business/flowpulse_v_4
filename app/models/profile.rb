class Profile < ApplicationRecord
  belongs_to :user
  has_many :ports, dependent: :destroy
  has_many :webapp_domains, through: :ports
  has_many :sea_routes, dependent: :destroy

  VISIBILITIES = %w[private public].freeze
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  before_validation :set_slug

  validates :display_name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :slug, format: { with: SLUG_FORMAT }
  validates :visibility, presence: true, inclusion: { in: VISIBILITIES }

  def creator?
    creator_enabled_until.present? && creator_enabled_until.future?
  end

  def creator_requested?
    if has_attribute?(:creator_requested)
      self[:creator_requested]
    elsif has_attribute?(:creator_requested_at)
      self[:creator_requested_at].present?
    else
      false
    end
  end

  def professional?
    professional_enabled_until.present? && professional_enabled_until.future?
  end

  def professional_requested?
    if has_attribute?(:professional_requested)
      self[:professional_requested]
    elsif has_attribute?(:professional_requested_at)
      self[:professional_requested_at].present?
    else
      false
    end
  end

  def traveler_only?
    !creator? && !professional?
  end

  def access_role_label
    return "Creator + Professional" if creator? && professional?
    return "Creator" if creator?
    return "Professional" if professional?

    "Viaggiatore"
  end

  def creator_status_label
    return "Abilitato" if creator?
    return "Richiesta inviata" if creator_requested?

    "Non richiesto"
  end

  def professional_status_label
    return "Abilitato" if professional?
    return "Richiesta inviata" if professional_requested?

    "Non richiesto"
  end

  def creator_active_until_label
    return if creator_enabled_until.blank?

    I18n.l(creator_enabled_until.to_date, format: :long)
  end

  def creator_active_from_label
    return if creator_enabled_until.blank?

    I18n.l((creator_enabled_until - 1.year).to_date, format: :long)
  end

  def professional_active_until_label
    return if professional_enabled_until.blank?

    I18n.l(professional_enabled_until.to_date, format: :long)
  end

  def professional_active_from_label
    return if professional_enabled_until.blank?

    I18n.l((professional_enabled_until - 1.year).to_date, format: :long)
  end

  def creator_admin_status_label
    return "Attivo fino al #{creator_active_until_label}" if creator?
    return "Richiesta in attesa" if creator_requested?

    "Non attivo"
  end

  def professional_admin_status_label
    return "Attivo fino al #{professional_active_until_label}" if professional?
    return "Richiesta in attesa" if professional_requested?

    "Non attivo"
  end

  def created_at_compact_label
    return if created_at.blank?

    I18n.l(created_at.to_date, format: "%-d %b %Y")
  end

  def creator_requested_compact_label
    return if self[:creator_requested_at].blank?

    I18n.l(self[:creator_requested_at].to_date, format: "%-d %b %Y")
  end

  def professional_requested_compact_label
    return if self[:professional_requested_at].blank?

    I18n.l(self[:professional_requested_at].to_date, format: "%-d %b %Y")
  end

  def creator_active_range_compact_label
    return if creator_enabled_until.blank?

    "#{creator_active_from_compact_label} → #{creator_active_until_compact_label}"
  end

  def professional_active_range_compact_label
    return if professional_enabled_until.blank?

    "#{professional_active_from_compact_label} → #{professional_active_until_compact_label}"
  end

  private
    def creator_active_from_compact_label
      I18n.l((creator_enabled_until - 1.year).to_date, format: "%-d %b %Y")
    end

    def creator_active_until_compact_label
      I18n.l(creator_enabled_until.to_date, format: "%-d %b %Y")
    end

    def professional_active_from_compact_label
      I18n.l((professional_enabled_until - 1.year).to_date, format: "%-d %b %Y")
    end

    def professional_active_until_compact_label
      I18n.l(professional_enabled_until.to_date, format: "%-d %b %Y")
    end

    def set_slug
      base_value = display_name.presence || user&.email_address&.split("@")&.first
      return if base_value.blank?

      base_slug = base_value.parameterize
      return if base_slug.blank?

      self.slug = unique_slug_for(base_slug) if slug.blank?
    end

    def unique_slug_for(base_slug)
      candidate = base_slug
      suffix = 2

      while Profile.where.not(id: id).exists?(slug: candidate)
        candidate = "#{base_slug}-#{suffix}"
        suffix += 1
      end

      candidate
    end
end
