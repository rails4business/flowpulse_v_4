class SeaRoute < ApplicationRecord
  belongs_to :profile
  belongs_to :source_port, class_name: "Port"
  belongs_to :target_port, class_name: "Port"

  before_validation :set_default_bidirectional, :assign_position, on: :create

  validates :source_port_id, uniqueness: { scope: [:profile_id, :target_port_id] }
  validates :bidirectional, inclusion: { in: [true, false] }
  validates :position, numericality: { greater_than: 0 }
  validate :ports_must_be_distinct
  validate :ports_must_belong_to_profile
  validate :route_pair_must_be_unique_regardless_of_direction

  scope :ordered, -> { order(:position, :id) }

  def directed?
    !bidirectional?
  end

  def toggle_bidirectional!
    update!(bidirectional: !bidirectional?)
  end

  def invert_direction!
    update!(source_port: target_port, target_port: source_port, bidirectional: false)
  end

  def set_direction_state!(state)
    case state.to_s
    when "bidirectional"
      update!(bidirectional: true)
    when "source_to_target"
      update!(bidirectional: false)
    when "target_to_source"
      invert_direction!
    else
      errors.add(:base, "Stato direzione non valido")
      raise ActiveRecord::RecordInvalid, self
    end
  end

  private
    def set_default_bidirectional
      self.bidirectional = false if bidirectional.nil?
    end

    def assign_position
      return if position.present?
      return if profile_id.blank? || source_port_id.blank?

      self.position = next_position
    end

    def next_position
      self.class.where(profile_id: profile_id, source_port_id: source_port_id).maximum(:position).to_i + 1
    end

    def ports_must_be_distinct
      return if source_port_id.blank? || target_port_id.blank?
      return unless source_port_id == target_port_id

      errors.add(:target_port_id, "must be different from source port")
    end

    def ports_must_belong_to_profile
      return if profile.blank?

      [source_port, target_port].compact.each do |port|
        next if port.profile_id == profile_id

        errors.add(:base, "Ports must belong to the same profile")
      end
    end

    def route_pair_must_be_unique_regardless_of_direction
      return if profile_id.blank? || source_port_id.blank? || target_port_id.blank?

      existing_route = self.class
        .where(profile_id: profile_id)
        .where(
          "(source_port_id = :source_id AND target_port_id = :target_id) OR (source_port_id = :target_id AND target_port_id = :source_id)",
          source_id: source_port_id,
          target_id: target_port_id
        )
        .where.not(id: id)
        .exists?

      return unless existing_route

      errors.add(:base, "Sea route già esistente tra questi due porti")
    end
end
