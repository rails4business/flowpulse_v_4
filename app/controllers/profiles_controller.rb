class ProfilesController < ApplicationController
  before_action :require_superadmin, only: %i[toggle_creator toggle_professional]

  def new
    redirect_to dashboard_path if Current.session.user.profile.present?

    @profile = Profile.new(visibility: "private")
  end

  def create
    if Current.session.user.profile.present?
      redirect_to dashboard_path
      return
    end

    @profile = Current.session.user.build_profile(profile_params)

    if @profile.save
      redirect_to dashboard_path, notice: "Profilo completato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = Current.session.user.profile
  end

  def update
    @profile = Current.session.user.profile

    if @profile.update(profile_params)
      redirect_to dashboard_path, notice: "Profilo aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def request_creator
    @profile = Current.session.user.profile

    if @profile.creator?
      redirect_to dashboard_path, notice: "Accesso creator gia' abilitato."
    elsif @profile.creator_requested?
      redirect_to dashboard_path, notice: "Richiesta creator gia' inviata."
    else
      @profile.update!(creator_request_attributes)
      redirect_to dashboard_path, notice: "Richiesta creator inviata."
    end
  end

  def request_professional
    @profile = Current.session.user.profile

    if @profile.professional?
      redirect_to dashboard_path, notice: "Accesso professional gia' abilitato."
    elsif @profile.professional_requested?
      redirect_to dashboard_path, notice: "Richiesta professional gia' inviata."
    else
      @profile.update!(professional_request_attributes)
      redirect_to dashboard_path, notice: "Richiesta professional inviata."
    end
  end

  def toggle_creator
    @profile = Profile.find(params[:id])
    enabled = ActiveModel::Type::Boolean.new.cast(params[:enabled])

    attributes = { creator_enabled_until: enabled ? 1.year.from_now : nil }
    attributes.merge!(clear_creator_request_attributes) if enabled

    @profile.update!(attributes)
    redirect_back fallback_location: dashboard_path, notice: enabled ? "Accesso creator abilitato." : "Accesso creator disabilitato."
  end

  def toggle_professional
    @profile = Profile.find(params[:id])
    enabled = ActiveModel::Type::Boolean.new.cast(params[:enabled])

    attributes = { professional_enabled_until: enabled ? 1.year.from_now : nil }
    attributes.merge!(clear_professional_request_attributes) if enabled

    @profile.update!(attributes)
    redirect_back fallback_location: dashboard_path, notice: enabled ? "Accesso professional abilitato." : "Accesso professional disabilitato."
  end

  private
    def creator_request_attributes
      if Profile.column_names.include?("creator_requested")
        { creator_requested: true }
      else
        { creator_requested_at: Time.current }
      end
    end

    def professional_request_attributes
      if Profile.column_names.include?("professional_requested")
        { professional_requested: true }
      else
        { professional_requested_at: Time.current }
      end
    end

    def clear_creator_request_attributes
      if Profile.column_names.include?("creator_requested")
        { creator_requested: false }
      else
        { creator_requested_at: nil }
      end
    end

    def clear_professional_request_attributes
      if Profile.column_names.include?("professional_requested")
        { professional_requested: false }
      else
        { professional_requested_at: nil }
      end
    end

    def profile_params
      params.require(:profile).permit(:display_name, :bio, :visibility)
    end
end
