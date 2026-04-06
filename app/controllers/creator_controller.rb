class CreatorController < ApplicationController
  before_action :require_creator

  def map_index
  end

  def branch_map
  end

  def journey
  end

  def value_architecture
  end

  private

  def require_creator
    redirect_to dashboard_path, alert: "Accesso creator non abilitato." unless Current.session.user.profile&.creator?
  end
end
