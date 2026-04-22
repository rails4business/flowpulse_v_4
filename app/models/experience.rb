class Experience < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  belongs_to :port
  belongs_to :parent_experience, class_name: "Experience", optional: true
  has_many :stations, -> { order(:position, :created_at) }, dependent: :restrict_with_exception
  has_many :child_experiences, -> { order(:position, :created_at) }, class_name: "Experience", foreign_key: :parent_experience_id, dependent: :nullify

  enum :experience_kind, { lesson: 0, program: 1, quiz: 2, blog: 3, book: 4, course: 5, exercise: 6, page: 7, video: 8, sheet: 9 }

  before_validation :set_slug_from_name, :normalize_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :port_id }, format: { with: SLUG_FORMAT }
  validates :position, numericality: { only_integer: true }
  validate :parent_experience_must_not_be_self
  validate :parent_experience_must_belong_to_same_port

  def experience_kind_label
    experience_kind&.humanize || "Experience"
  end

  private
    def parent_experience_must_not_be_self
      return if parent_experience_id.blank? || parent_experience_id != id

      errors.add(:parent_experience_id, "cannot point to the same experience")
    end

    def parent_experience_must_belong_to_same_port
      return if parent_experience.blank? || port.blank?
      return if parent_experience.port_id == port_id

      errors.add(:parent_experience_id, "must belong to the same port")
    end

    def set_slug_from_name
      return if slug.present? || name.blank?

      self.slug = name.parameterize
    end

    def normalize_slug
      return if slug.blank?

      self.slug = slug.to_s.parameterize
    end
end
