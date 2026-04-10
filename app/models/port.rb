class Port < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  HEX_COLOR_FORMAT = /\A#(?:[0-9a-f]{6})\z/i

  belongs_to :profile
  belongs_to :brand_port, class_name: 'Port', optional: true

  enum :port_kind, { brand: 0, map_port: 1, blog: 2, book: 3 }
  enum :visibility, { draft: 0, published: 1, hidden: 2 }

  before_validation :set_slug_from_name, :normalize_color_key, :set_default_color_key

  def port_kind_label
    return "Map" if map_port?

    port_kind.humanize
  end

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :profile_id }
  validates :slug, format: { with: SLUG_FORMAT }
  validates :x, :y, numericality: { only_integer: true }, allow_nil: true
  validates :color_key, format: { with: HEX_COLOR_FORMAT }, allow_blank: true

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
      when "brand" then "#dc2626"
      when "map_port" then "#2563eb"
      when "blog" then "#d97706"
      when "book" then "#16a34a"
      else "#475569"
      end
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
