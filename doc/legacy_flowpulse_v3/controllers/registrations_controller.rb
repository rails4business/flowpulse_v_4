# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout "posts", only: %i[new create]

  def new
    @lead ||= Lead.new
    @referrer = locate_referrer(params[:ref], params.dig(:lead, :referral_code))
    @user = User.new
    if params[:ref].present? && @referrer.nil?
      flash.now[:alert] = "Link invito non valido, scaduto o referrer non abilitato."
    elsif @referrer && !@referrer.can_invite?
      flash.now[:alert] = "Questo invito non è più disponibile."
      @referrer = nil
    end
  end

  def create
    referrer = locate_referrer(params[:ref], signup_params[:referral_code])

    email    = signup_params[:email].to_s.strip
    password = signup_params[:password]
    provisional_username = generate_username_from(email)

    # se il referrer non è abilitato, ignoralo
    referrer = nil unless referrer&.can_invite?

    flow = LeadSignupFlow.new.call!(
      lead_params: { email: email, username: provisional_username },
      password: password,
      referral_lead_id: nil,   # se in futuro salvi l'albero referral tra Lead, passa l'id qui
      auto_approve: false      # niente automatismi: approverai da superadmin
    )

    # collega il referrer (se usi questo campo su users)
    flow.user.update!(referrer_id: referrer.id) if referrer && flow.user.respond_to?(:referrer_id)
    ensure_default_domain_membership!(flow.lead)

    start_new_session_for(flow.user)
    referrer&.count_successful_invite!

    redirect_to after_authentication_url, notice: "Benvenuto! Account creato."
  rescue ActiveRecord::RecordInvalid => e
    @lead = Lead.new(signup_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  def edit
    @user = Current.user
    # prova a recuperare un lead esistente partendo dall'email dell'utente
    email = @user.try(:email_address) || @user.try(:email)
    @lead = @user.lead || Lead.find_by(email: email) || Lead.new(email: email, username: default_username(@user))
  end

  def update
    @user = Current.user
    email = @user.try(:email_address) || @user.try(:email)
    @lead = @user.lead || Lead.find_by(email: email) || Lead.new(email: email, username: default_username(@user))
    superadmin_toggle_request = params.dig(:user, :from_superadmin_toggle).to_s == "1"

    ActiveRecord::Base.transaction do
      @user.update!(user_params)

      if @lead.new_record?
        @lead.assign_attributes(lead_params)
        @lead.save!
        # 🔁 verso giusto: collega dall'utente al lead
        @user.update!(lead: @lead) if @user.lead_id.nil? || @user.lead_id != @lead.id
      else
        @lead.update!(lead_params)
        # assicurati che il legame ci sia
        @user.update!(lead: @lead) if @user.lead_id.nil?
      end
    end

    redirect_target = superadmin_toggle_request ? dashboard_home_path : after_authentication_url
    redirect_to redirect_target, notice: "Profilo aggiornato!"
  rescue ActiveRecord::RecordInvalid => e
    @lead ||= Lead.new
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  private

  def locate_referrer(signed_ref, legacy_ref_code)
    # 1) token firmato
    if signed_ref.present?
      user = User.find_signed(signed_ref, purpose: :referral) rescue nil
      return user if user&.approved_referrer?
    end

    # 2) fallback legacy: username di un Lead → suo user
    if legacy_ref_code.present?
      lead = Lead.find_by(username: legacy_ref_code)
      user = lead&.user
      return user if user&.approved_referrer?
    end

    nil
  end

  def user_params
    # se usi :email_address mantienilo qui; se usi :email, adegua
    allowed = [ :name, :surname, :phone, :email_address, :password, :password_confirmation ]
    allowed << :superadmin_mode_active if Current.user&.superadmin?
    params.require(:user).permit(*allowed)
  end

  def lead_params
    params.fetch(:lead, {}).permit(:username, :phone, :notes)
  end

  def default_username(user)
    base = (user.try(:email_address) || user.try(:email)).to_s.split("@").first.to_s
    base.parameterize.presence || "utente"
  end

  def signup_params
    params.require(:lead).permit(:email, :password, :referral_code)
  end

  def generate_username_from(email)
    base = email.to_s.split("@").first.to_s.parameterize.presence || "user"
    uname = base
    i = 1
    while Lead.exists?(username: uname)
      i += 1
      uname = "#{base}-#{i}"
      break if i > 1000
    end
    uname
  end

  def ensure_default_domain_membership!(lead)
    domain = Current.domain
    return if domain.blank? || lead.blank?

    membership = lead.domain_memberships.find_or_initialize_by(domain: domain)
    membership.status = :active
    membership.domain_active_role = membership.domain_active_role.presence || "member"

    has_primary = lead.domain_memberships.where(primary: true).where.not(id: membership.id).exists?
    membership.primary = !has_primary if membership.primary.nil?

    membership.save!
  end
end
