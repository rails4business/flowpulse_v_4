class Station < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  belongs_to :line
  belongs_to :experience, optional: true
  belongs_to :link_station, class_name: "Station", optional: true
  belongs_to :link_port, class_name: "Port", optional: true

  enum :station_kind, { normal: 0, branch: 1, gate: 2 }
  enum :shared_group_angle, { horizontal: 0, vertical: 1, diagonal_up: 2, diagonal_down: 3 }

  before_validation :set_slug_from_name, :normalize_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :line_id }, format: { with: SLUG_FORMAT }
  validates :position, numericality: { only_integer: true }
  validates :link_order, numericality: { only_integer: true }
  validates :map_x, :map_y, numericality: { only_integer: true }, allow_nil: true
  validate :experience_presence_matches_station_role
  validate :linked_station_must_not_be_self
  validate :linked_station_must_belong_to_different_line

  def connector?
    link_station_id.present?
  end

  def primary_station?
    !connector?
  end

  def primary_station
    link_station || self
  end

  def canonical_experience
    primary_station.experience
  end

  def port_entry?
    !!self[:port_entry]
  end

  def station_kind_label
    station_kind&.humanize || "Station"
  end

  def opening?
    return false if connector?
    return false if line.blank? || position.nil?

    line.stations.where.not(id: id).minimum(:position).nil? || position <= line.stations.where.not(id: id).minimum(:position).to_i
  end

  def closing?
    return false if connector?
    return false if line.blank? || position.nil?

    line.stations.where.not(id: id).maximum(:position).nil? || position >= line.stations.where.not(id: id).maximum(:position).to_i
  end

  def step?
    !opening? && !closing?
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

    def experience_presence_matches_station_role
      if connector?
        return if experience_id.blank?

        errors.add(:experience_id, "must be empty for connector stations")
      else
        return if experience.present?

        errors.add(:experience, "must exist for primary stations")
      end
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
