module Admin
  class UsersController < ApplicationController
    before_action :require_superadmin

    def index
      @filter = params[:filter].in?(%w[all with_profile without_profile superadmin]) ? params[:filter] : "all"
      @users = base_scope
    end

    private
      def base_scope
        scope = User.includes(:profile).order(created_at: :desc)

        case @filter
        when "with_profile"
          scope.where.associated(:profile)
        when "without_profile"
          scope.where.missing(:profile)
        when "superadmin"
          scope.where(superadmin: true)
        else
          scope
        end
      end
  end
end
