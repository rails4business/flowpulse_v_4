class ProfessionalsController < ApplicationController
  before_action :require_professional

  def index
  end

  def catalog
  end

  def value
  end

  def titles
  end

  private
    def require_professional
      redirect_to dashboard_path, alert: "Accesso professional non abilitato." unless Current.session.user.profile&.professional?
    end
end
