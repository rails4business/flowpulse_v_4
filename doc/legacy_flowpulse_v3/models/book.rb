class Book < ApplicationRecord
  has_many :book_domains, dependent: :destroy
  has_many :domains, through: :book_domains
  has_one_attached :cover_image

  scope :active, -> { where(active: true) }

  enum :access_mode, {
    hidden: 0,
    draft: 1,
    free: 2,
    registered: 3,
    payment: 4
  }, prefix: :book_access

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validate :cover_image_is_valid

  private

  def cover_image_is_valid
    return unless cover_image.attached?

    allowed_types = %w[image/png image/jpeg image/webp]
    unless allowed_types.include?(cover_image.blob.content_type)
      errors.add(:cover_image, "deve essere PNG, JPG o WEBP")
    end

    if cover_image.blob.byte_size > 8.megabytes
      errors.add(:cover_image, "deve essere massimo 8MB")
    end
  end
end
