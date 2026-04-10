# app/controllers/concerns/current_domain_context.rb
module CurrentDomainContext
  extend ActiveSupport::Concern

  included do
    before_action :set_current_domain_and_taxbranch
    helper_method :current_domain
  end

  private

  def set_current_domain_and_taxbranch
    host = normalize_host(request.host)
    Current.domain    = Domain.includes(:taxbranch).find_by(host: host)
    Current.taxbranch = Current.domain&.taxbranch
  end

  def current_domain
    Current.domain
  end

  def normalize_host(h)
    h.to_s.strip.downcase
      .sub(/\Ahttps?:\/\//, "")
      .sub(/\Awww\./, "")
      .split(":").first
  end
end
