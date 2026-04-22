class WebappDomain < ApplicationRecord
  HEX_COLOR_FORMAT = /\A#(?:[0-9a-f]{6})\z/i
  HOST_FORMAT = /\A[a-z0-9.-]+\.[a-z]{2,}\z/i
  AVAILABLE_HOME_PAGE_KEYS = %w[posturacorretta_home].freeze

  belongs_to :brand_port, class_name: "Port"

  before_validation :normalize_host, :normalize_locale
  before_save :unset_other_primary_domains, if: :primary?

  validates :host, presence: true, uniqueness: true, format: { with: HOST_FORMAT }
  validates :locale, presence: true
  validates :home_page_key, inclusion: { in: AVAILABLE_HOME_PAGE_KEYS }, allow_blank: true
  validates :header_bg_color, :header_text_color, :accent_color, :background_color,
    format: { with: HEX_COLOR_FORMAT }, allow_blank: true
  validate :brand_port_must_be_brand

  private
    def normalize_host
      self.host = normalize_host_value(host)
    end

    def normalize_locale
      self.locale = locale.to_s.strip.presence&.downcase
    end

    def unset_other_primary_domains
      brand_port.webapp_domains.where.not(id: id).where(primary: true).update_all(primary: false)
    end

    def brand_port_must_be_brand
      return if brand_port.blank?
      return if brand_port.web_app?

      errors.add(:brand_port, "must be a web app port")
    end

  private
    def normalize_host_value(value)
      normalized = value.to_s.strip.downcase
      normalized.sub(/\Awww\./, "")
    end
end
