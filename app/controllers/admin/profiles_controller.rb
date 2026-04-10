module Admin
  class ProfilesController < ApplicationController
    before_action :require_superadmin

    def index
      redirect_to admin_users_path(filter: params[:filter].presence || "all")
    end
  end
end
