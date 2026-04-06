module Admin
  class CreatorRequestsController < ApplicationController
    before_action :require_superadmin

    def index
      @requested_profiles = Profile.includes(:user).where(creator_requested: true, creator_enabled: false).order(updated_at: :desc)
      @enabled_profiles = Profile.includes(:user).where(creator_enabled: true).order(updated_at: :desc)
    end
  end
end
