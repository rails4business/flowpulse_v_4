class Domain < ApplicationRecord
  store_accessor :aree_ruoli
  belongs_to :taxbranch
  has_many :domain_memberships, dependent: :destroy
  has_many :leads, through: :domain_memberships
  has_many :certificates, dependent: :nullify
  #  belongs_to :owner, class_name: "Lead", optional: true

  validates :host, presence: true, uniqueness: true
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache
  validates :host, presence: true, uniqueness: { case_sensitive: false }
  validates :language, presence: true

  before_validation :normalize_host!
  after_commit :clear_cache

  def operative_roles=(value)
    parsed =
      case value
      when String
        value.split(/[\n,;]/).map { |entry| entry.strip.presence }.compact
      when Array
        value.map { |entry| entry.to_s.strip.presence }.compact
      else
        value
      end

    super(parsed)
  end

  def operative_roles_text
    Array(operative_roles).join("\n")
  end

  # Backward compatibility for old calls still using role_areas naming.
  def role_areas=(value)
    self.operative_roles = value
  end

  def role_areas_text
    operative_roles_text
  end

  private

  def normalize_host!
    return if host.blank?

    h = host.to_s.strip.downcase
    h = h.sub(/\Ahttps?:\/\//, "")
    h = h.sub(/\Awww\./, "")
    h = h.split(":").first
    self.host = h
  end

  def clear_cache
    Rails.cache.delete("domain:#{host}")
  end
end
