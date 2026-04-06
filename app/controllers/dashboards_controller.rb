class DashboardsController < ApplicationController
  def show
    if Current.session.user.profile.blank?
      redirect_to new_profile_path, notice: "Completa prima il profilo."
    end
  end
end
