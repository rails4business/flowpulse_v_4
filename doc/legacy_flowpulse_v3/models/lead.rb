# app/models/lead.rb
class Lead < ApplicationRecord
  has_one :user, dependent: :nullify
  has_many :taxbranches
  has_many :journeys
  has_many :posts, inverse_of: :lead, dependent: :nullify
  has_many :contacts, dependent: :destroy
  has_many :datacontacts, dependent: :nullify
  has_many :mycontacts, dependent: :destroy
  has_many :tag_positionings, dependent: :destroy
  has_many :certificates, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :domain_memberships, dependent: :destroy
  has_many :domains, through: :domain_memberships


  belongs_to :parent,        class_name: "Lead", optional: true
  belongs_to :referral_lead, class_name: "Lead", optional: true
  has_many   :children,      class_name: "Lead", foreign_key: :parent_id, dependent: :nullify

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-zA-Z0-9._\-]+\z/ },
    if: -> { self.respond_to?(:username) && username.present? && self.class.column_names.include?("username") }

    validates :token,    presence: true, uniqueness: true

  before_validation :ensure_token

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(20)
  end

  def full_name
    [ name, surname ].compact_blank.join(" ")
  end

  def enrollments
    Enrollment.where(mycontact_id: mycontacts.select(:id))
  end

  def active_domains
    explicit_domains = domain_memberships.active.includes(:domain).map(&:domain).compact
    enrolled_domains = enrollments.includes(service: { taxbranch: :domains }).map(&:domain).compact
    (explicit_domains + enrolled_domains).uniq
  end
end
