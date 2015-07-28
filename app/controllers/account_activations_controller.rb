class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # activation token is as params[:id] because of the url:
    # http://www.example.com/account_activations/q5lt38hQDc_959PVoo6b7A/edit
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
