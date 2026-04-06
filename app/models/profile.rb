class Profile < ApplicationRecord
  belongs_to :user

  VISIBILITIES = %w[private public].freeze
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  before_validation :set_slug

  validates :display_name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :slug, format: { with: SLUG_FORMAT }
  validates :visibility, presence: true, inclusion: { in: VISIBILITIES }

  def creator?
    creator_enabled
  end

  def creator_requested?
    creator_requested
  end

  def traveler_only?
    !creator_enabled
  end

  def creator_status_label
    return "Abilitato" if creator?
    return "Richiesta inviata" if creator_requested?

    "Non richiesto"
  end

  private
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
