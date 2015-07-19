class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password]) # authenticate method provided by has_secure_password
  		log_in user # defined in sessions helper
  		params[:session][:remember_me] == '1' ? remember(user) : forget(user) #defined in session helpers
      redirect_to user # equals redirect_to user_url(user)
  	else
  		flash.now[:danger] = 'Invalid email/password combination' # not quite right
  		render 'new'
  	end
  end

  def destroy
  	log_out if logged_in?
  	redirect_to root_url
  end
end
