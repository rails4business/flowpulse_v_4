class Line < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  HEX_COLOR_FORMAT = /\A#(?:[A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})\z/

  belongs_to :port
  has_one :content, as: :contentable, dependent: :destroy
  has_many :stations, -> { order(:position, :created_at) }, dependent: :destroy

  enum :line_kind, { trail: 0, branch: 1, folder: 2, route: 3 }
  accepts_nested_attributes_for :content, update_only: true

  before_validation :set_slug_from_name, :normalize_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :port_id }, format: { with: SLUG_FORMAT }
  validates :position, numericality: { only_integer: true }
  validates :color, format: { with: HEX_COLOR_FORMAT }, allow_blank: true

  def line_kind_label
    line_kind&.humanize || "Line"
  end

  private
    def set_slug_from_name
      return if slug.present? || name.blank?

      self.slug = name.parameterize
    end

    def normalize_slug
      return if slug.blank?

      self.slug = slug.to_s.parameterize
    end
end
