class ApplicationController < ActionController::Base
  include CurrentDomainContext
  include Authentication
  include Pundit::Authorization

  # Rende policy()/policy_scope() disponibili anche nelle view
  helper_method :policy, :policy_scope

  # Sempre valorizza Current.session se esiste un cookie, anche nelle pagine pubbliche.
  before_action :resume_session
  before_action :ensure_default_domain_membership

  # >>> Dillo a Pundit: l'utente corrente è Current.user (non current_user)
  def pundit_user
    Current.user
  end

  # (Consigliato) gestione elegante dei divieti
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized




  def pundit_user = Current.user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def ensure_default_domain_membership
    return unless defined?(DomainMembership) && DomainMembership.table_exists?

    lead = Current.user&.lead
    domain = Current.domain
    return if lead.blank? || domain.blank?
    return if lead.domain_memberships.exists?

    lead.domain_memberships.create!(
      domain: domain,
      status: :active,
      primary: true,
      domain_active_role: "member"
    )
  rescue StandardError => e
    Rails.logger.warn("[DomainMembership] auto-assign skipped: #{e.class} - #{e.message}")
  end

  def user_not_authorized
    redirect_to(request.referer || root_path, alert: "Non hai i permessi per questa azione.")
  end
end
