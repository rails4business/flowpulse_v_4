# app/controllers/account/leads_controller.rb
class Account::LeadsController < ApplicationController
   # before_action :require_tutor!
   # before_action :ensure_lead!, only: [ :index, :create ]





   def index
      @me      = Current.user
      @my_lead = @me.lead || Lead.find_by(email: @me.email_address) ||
                Lead.create!(email: @me.email_address, username: default_username(@me), user_id: @me.id, token: SecureRandom.hex(16))

      @invited_leads = Lead.includes(:user)
                          .where(referral_lead_id: @my_lead.id)
                          .order(created_at: :desc)

      base = Lead.left_outer_joins(:user).where(referral_lead_id: @my_lead.id)

      @counts = {
        "all"      => base.count,
        # pending = user pending O lead senza user (non registrato)
        "pending"  => base.where(users: { state_registration: User.state_registrations[:pending] })
                          .or(base.where(users: { id: nil })).distinct.count,
        "approved" => base.where(users: { state_registration: User.state_registrations[:approved] }).distinct.count,
        "rejected" => base.where(users: { state_registration: User.state_registrations[:rejected] }).distinct.count
      }

      @new_lead = Lead.new
    end


  def create
    me      = Current.user
    my_lead = me.lead || Lead.find_by(email: me.email_address) ||
               Lead.create!(email: me.email_address, username: default_username(me), user_id: me.id, token: SecureRandom.hex(16))

    email    = lead_params[:email].to_s.strip.downcase
    name     = lead_params[:name].presence
    surname  = lead_params[:surname].presence
    username = generate_username_from(email)

    Lead.create!(
      email:             email,
      name:              name,
      surname:           surname,
      username:          username,
      referral_lead_id:  my_lead.id,
      token:             SecureRandom.hex(16)
    )

    redirect_to account_leads_path, notice: "Invito creato."
  rescue ActiveRecord::RecordInvalid => e
    @invited_leads = Lead.where(referral_lead_id: my_lead.id).order(created_at: :desc)
    @new_lead      = Lead.new(lead_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :index, status: :unprocessable_entity
  end

  def destroy
    me      = Current.user
    my_lead = me.lead || Lead.find_by(email: me.email_address)
    lead    = Lead.where(referral_lead_id: my_lead&.id).find(params[:id])
    lead.destroy!
    redirect_to account_leads_path, notice: "Invitato rimosso."
  end




  private

  def require_tutor!
    # unless Current.user&.has_role?(:tutor) || Current.user&.has_role?(:team_manager)
    unless Current.user.superadmin == "true"


     redirect_to account_leads_path, alert: "Non autorizzato."
    end
  end

  def lead_params
    params.require(:lead).permit(:email, :name, :surname)
  end


  def default_username(user)
    user.email_address.to_s.split("@").first.to_s.parameterize.presence || "utente"
  end

  def ensure_lead!
    user = Current.user
    return unless user

    user.lead || Lead.find_by(email: user.email_address) ||
      Lead.create!(email: user.email_address,
                  username: default_username(user),
                  user_id: user.id,
                  token: SecureRandom.hex(16))
  end

  def generate_username_from(email)
    base = email.split("@").first.to_s.parameterize.presence || "utente"
    uname = base
    i = 1
    while Lead.exists?(username: uname)
      i += 1
      uname = "#{base}-#{i}"
      break if i > 1000
    end
    uname
  end
end
