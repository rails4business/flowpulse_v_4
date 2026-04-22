class Station < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  belongs_to :line
  belongs_to :experience
  belongs_to :link_station, class_name: "Station", optional: true
  belongs_to :link_port, class_name: "Port", optional: true

  enum :station_kind, { step: 0, branch: 1, gate: 2, page: 3, opening: 4, closing: 5 }

  before_validation :set_slug_from_name, :normalize_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :line_id }, format: { with: SLUG_FORMAT }
  validates :position, numericality: { only_integer: true }
  validates :map_x, :map_y, numericality: { only_integer: true }, allow_nil: true
  validate :linked_station_must_not_be_self
  validate :linked_station_must_belong_to_different_line

  def station_kind_label
    case station_kind
    when "opening" then "Apertura"
    when "closing" then "Chiusura"
    else
      station_kind&.humanize || "Station"
    end
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

    def linked_station_must_not_be_self
      return if link_station_id.blank? || link_station_id != id

      errors.add(:link_station_id, "cannot point to the same station")
    end

    def linked_station_must_belong_to_different_line
      return if link_station.blank? || line.blank?
      return if link_station.line_id != line_id

      errors.add(:link_station_id, "must point to a station in another line")
    end
end
