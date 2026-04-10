module Admin
  class CreatorRequestsController < ApplicationController
    before_action :require_superadmin

    def index
      @scope = params[:scope].in?(%w[all creator professional]) ? params[:scope] : "all"
      @status = params[:status].in?(%w[requested enabled inactive]) ? params[:status] : "requested"
      @requested_profiles = requested_creator_scope.order(updated_at: :desc)
      @enabled_profiles = Profile.includes(:user).where("creator_enabled_until > ?", Time.current).order(updated_at: :desc)
      @inactive_creator_profiles = expired_creator_scope.order(creator_enabled_until: :desc)
      @requested_professionals = requested_professional_scope.order(updated_at: :desc)
      @enabled_professionals = Profile.includes(:user).where("professional_enabled_until > ?", Time.current).order(updated_at: :desc)
      @inactive_professional_profiles = expired_professional_scope.order(professional_enabled_until: :desc)
    end

    private
      def requested_creator_scope
        if Profile.column_names.include?("creator_requested")
          Profile.includes(:user).where(creator_requested: true, creator_enabled_until: nil)
        else
          Profile.includes(:user).where.not(creator_requested_at: nil).where(creator_enabled_until: nil)
        end
      end

      def expired_creator_scope
        Profile.includes(:user).where.not(creator_enabled_until: nil).where("creator_enabled_until <= ?", Time.current)
      end

      def requested_professional_scope
        if Profile.column_names.include?("professional_requested")
          Profile.includes(:user).where(professional_requested: true, professional_enabled_until: nil)
        else
          Profile.includes(:user).where.not(professional_requested_at: nil).where(professional_enabled_until: nil)
        end
      end

      def expired_professional_scope
        Profile.includes(:user).where.not(professional_enabled_until: nil).where("professional_enabled_until <= ?", Time.current)
      end
  end
end
