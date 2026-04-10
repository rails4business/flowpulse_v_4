# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  belongs_to :lead, optional: true
  belongs_to :referrer, class_name: "User", optional: true
  has_many   :sessions, dependent: :destroy

  # Normalizza la mail (usa UNA sola via: normalizes OR before_validation)
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Stato amministrativo “di comodo” (se lo usi davvero, vedi nota sotto)
  enum :state_registration, { pending: 0, approved: 1 }, default: :pending

  # Validazioni base
  validates :email_address, presence: true, uniqueness: true


  # estrai il ruolo senza esplodere se manca qualcosa
  def role_name
    if Current.user.superadmin == true # lead&.certificate&.role_name&.to_s&.downcase # => "admin", "tutor", "pro", "referrer", ...
      "superadmin"
    end
  end

  # predicati comodi (adatta ai tuoi nomi reali)
  def admin?    = role_name == "admin"
  def tutor?    = role_name == "tutor"
  def pro?      = role_name == "pro"      || role_name == "professionista"
  def referrer? = role_name == "referrer" || role_name == "segnalatore"

  # se ti serve ambito/centro, esponilo da lead (se esiste)
  def center_id
    lead&.center_id
  end
  # ---- APPROVAL ----
  def approved?
    approved_at.present?
  end

  # Chi approva è un Lead (Tutor/TeamManager). Salva su approved_by_lead_id.
  def approve!(approved_by_lead:)
    update!(
      approved_at: Time.current,
      approved_by_lead_id: approved_by_lead&.id,
      state_registration: :approved # <-- opzionale, vedi nota sotto
    )
  end

  # ---- REFERRAL ABILITAZIONE ----
  # Sei abilitato ad invitare? (adatta alla tua logica ruoli se li hai)
  def approved_referrer?
   approved? && tutor_or_manager?
  end

  # Limiti inviti
  def can_invite?
    approved_referrer? && invites_count < invites_limit
  end

  def remaining_invites
    [ invites_limit - invites_count, 0 ].max
  end

  # Token referral valido SOLO se puoi invitare
  def referral_token(expires_in: 14.days)
    return nil unless can_invite?
    signed_id(purpose: :referral, expires_in: expires_in)
  end

  def tutor_or_manager?
    self.superadmin == true
  end

  def referral_url(host:)
    tok = referral_token
    return nil unless tok

    host = host.to_s.strip
    return nil if host.blank?

    # assicura lo schema
    host = "https://#{host}" unless host.start_with?("http://", "https://")

    path = referral_path_for(tok)
    "#{host}#{path}"
  end

  # Aumenta conteggio inviti a registrazione riuscita
  def count_successful_invite!
    increment!(:invites_count)
  end

  def referral_path_for(token)
    h = Rails.application.routes.url_helpers
    if h.respond_to?(:new_registration_path)
      h.new_registration_path(ref: token)
    elsif h.respond_to?(:registration_new_path)
      h.registration_new_path(ref: token)
    else
      "/registration/new?ref=#{token}"
    end
  end
  # Accesso rapido ai campi del Lead (se presenti)
  delegate :name, :surname, :username, :email, to: :lead, prefix: true, allow_nil: true
end
