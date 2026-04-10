# class SessionsController < ApplicationController
#   allow_unauthenticated_access only: %i[ new create ]
#   rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }
#   layout "posts"
#   def new
#   end

#   def create
#     if user = User.authenticate_by(params.permit(:email_address, :password))
#       start_new_session_for user
#       redirect_to dashboard_home_path
#     else
#       redirect_to new_session_path, alert: "Try another email address or password."
#     end
#   end

#   def destroy
#     terminate_session
#     redirect_to new_session_path
#   end
# end


# app/controllers/sessions_controller.rb# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  layout "posts"

  def new
    redirect_to after_authentication_url if Current.user
  end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Bentornato!"
    else
      flash.now[:alert] = "Credenziali non valide."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Disconnesso."
  end
end
