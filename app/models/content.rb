class Content < ApplicationRecord
  belongs_to :contentable, polymorphic: true

  enum :visibility, { draft: 0, published: 1, hidden: 2 }

  def publicly_visible?
    return false unless published?
    return true if published_at.blank?

    published_at <= Time.current
  end

  def display_title
    contentable.try(:name).presence || contentable.try(:title).presence || contentable.class.model_name.human
  end

  def display_slug
    contentable.try(:slug)
  end
end
