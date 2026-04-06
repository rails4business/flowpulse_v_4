class ProfilesController < ApplicationController
  before_action :require_superadmin, only: :toggle_creator

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
      @profile.update!(creator_requested: true)
      redirect_to dashboard_path, notice: "Richiesta creator inviata."
    end
  end

  def toggle_creator
    @profile = Profile.find(params[:id])
    enabled = ActiveModel::Type::Boolean.new.cast(params[:enabled])

    attributes = { creator_enabled: enabled }
    attributes[:creator_requested] = false if enabled

    @profile.update!(attributes)
    redirect_back fallback_location: dashboard_path, notice: enabled ? "Accesso creator abilitato." : "Accesso creator disabilitato."
  end

  private
    def profile_params
      params.require(:profile).permit(:display_name, :bio, :visibility)
    end
end
