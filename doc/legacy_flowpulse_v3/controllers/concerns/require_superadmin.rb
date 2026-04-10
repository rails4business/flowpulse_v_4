# app/controllers/concerns/require_superadmin.rb
module RequireSuperadmin
  extend ActiveSupport::Concern

  included do
    before_action :require_superadmin!
  end

  private

  def require_superadmin!
    unless Current.user&.superadmin?
      redirect_to root_path, alert: "Non autorizzato."
    end
  end
end
