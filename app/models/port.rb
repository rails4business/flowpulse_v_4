class Port < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  HEX_COLOR_FORMAT = /\A#(?:[0-9a-f]{6})\z/i

  belongs_to :profile
  belongs_to :brand_port, class_name: 'Port', optional: true
  has_many :webapp_domains, class_name: "WebappDomain", foreign_key: :brand_port_id, dependent: :destroy
  has_many :outgoing_sea_routes, class_name: "SeaRoute", foreign_key: :source_port_id, dependent: :destroy
  has_many :incoming_sea_routes, class_name: "SeaRoute", foreign_key: :target_port_id, dependent: :destroy

  enum :port_kind, { web_app: 0, website: 1, youtube: 2, instagram: 3, whatsapp: 4, phone: 5 }
  enum :visibility, { draft: 0, published: 1, hidden: 2 }

  before_validation :set_slug_from_name, :normalize_color_key, :set_default_color_key

  def port_kind_label
    case port_kind
    when "web_app" then "Web App"
    when "website" then "Website"
    when "youtube" then "YouTube"
    when "instagram" then "Instagram"
    when "whatsapp" then "WhatsApp"
    when "phone" then "Phone"
    else port_kind.humanize
    end
  end

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :profile_id }
  validates :slug, format: { with: SLUG_FORMAT }
  validates :x, :y, numericality: { only_integer: true }, allow_nil: true
  validates :color_key, format: { with: HEX_COLOR_FORMAT }, allow_blank: true
  validate :brand_root_requires_web_app

  def color_config
    base = color_key.presence || default_color_key

    {
      fill: mix_with_white(base, 0.82),
      stroke: base,
      text: contrast_text_for(base)
    }
  end

  def brand_ring_color_config
    brand_port&.color_config || color_config
  end

  def inherited_brand_port
    return self if brand_root?
    return brand_port if brand_port.present?

    nil
  end

  def sea_routes
    SeaRoute.where("source_port_id = ? OR target_port_id = ?", id, id)
  end

  def public_webapp_ready?
    published? && web_app? && webapp_domains.where(published: true).exists?
  end

  private
    def set_slug_from_name
      return if slug.present?
      return if name.blank?

      self.slug = name.parameterize
    end

    def normalize_color_key
      self.color_key = color_key.to_s.downcase.presence
    end

    def set_default_color_key
      self.color_key = default_color_key if color_key.blank?
    end

    def default_color_key
      case port_kind
      when "web_app" then "#2563eb"
      when "website" then "#0f766e"
      when "youtube" then "#dc2626"
      when "instagram" then "#c026d3"
      when "whatsapp" then "#16a34a"
      when "phone" then "#d97706"
      else "#475569"
      end
    end

    def brand_root_requires_web_app
      return unless brand_root?
      return if web_app?

      errors.add(:brand_root, "can be enabled only for web app ports")
    end

    def mix_with_white(hex, ratio)
      r, g, b = hex_to_rgb(hex)
      mixed = [r, g, b].map { |channel| ((channel * (1 - ratio)) + (255 * ratio)).round }

      rgb_to_hex(mixed)
    end

    def contrast_text_for(hex)
      r, g, b = hex_to_rgb(hex)
      brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000

      brightness > 160 ? "#0f172a" : "#f8fafc"
    end

    def hex_to_rgb(hex)
      hex.delete_prefix("#").scan(/../).map(&:hex)
    end

    def rgb_to_hex(rgb)
      format("#%02x%02x%02x", *rgb)
    end
end
