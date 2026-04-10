class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_or_title, use: :slugged

  belongs_to :taxbranch, inverse_of: :post

  belongs_to :lead,      inverse_of: :posts



  # 🔁 Usa il workflow del taxbranch
  # (status, visibility, published_at, ecc.)
  delegate :status,
           :visibility,
           :published_at,
           :visible_for?,
           to: :taxbranch,
           prefix: true,
           allow_nil: true

  validates :title, presence: true
  validates :taxbranch_id, uniqueness: true
   # 🔎 Post pubblici e pubblicati di recente (in base al taxbranch)
   scope :published_recent, -> {
    joins(:taxbranch)
      .where(
        taxbranches: {
          status:     Taxbranch.statuses[:published],
          visibility: Taxbranch.visibilities[:public_node]
        }
      )
      .where("taxbranches.published_at IS NULL OR taxbranches.published_at <= ?", Time.current)
      .order("COALESCE(taxbranches.published_at, taxbranches.created_at) DESC")
  }
  # ✅ Etichetta da mostrare in backend
  def display_status
    return "Senza stato" unless taxbranch

    case taxbranch.status
    when "published"   then "Pubblicato"
    when "draft"       then "Bozza"
    when "in_review"   then "In revisione"
    when "archived"    then "Archivio"
    else "Sconosciuto"
    end
  end

  def visible_for?(user)
    return false unless user.present?

    case visibility.to_sym
    when :public_node
      true

    when :participants_only
      user.superadmin? ||
      user.lead&.participates_in?(self)

    when :shared_node
      user.superadmin? ||
      user.staff? ||
      user.lead_id == lead_id

    when :private_node
      user.superadmin? ||
      user.lead_id == lead_id
    else
      false
    end
  end

  def slug_or_title
    slug.presence || title
  end

  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_title?
  end
end
