module SessionsHelper
	
	# logs in the given user
	def log_in(user)
		session[:user_id] = user.id # why use id instead of email?
	end

	# remember a user in a persistent session.
	def remember(user)
	  user.remember
      cookies.permanent.signed[:user_id] = user.id
      cookies.permanent[:remember_token] = user.remember_token
	end

	# Return true if the given user is the current user.
	def current_user?(user)
	  user == current_user
	end

	#Return the user corresponding to the remember token cookie.
	def current_user
	  if (user_id = session[:user_id]) #if session of user id exists
		@current_user ||= User.find_by(id: session[:user_id])
	  elsif (user_id = cookies.signed[:user_id]) #if persistent session of user id exists.
	  	user = User.find_by(id: user_id)
	  	if user && user.authenticated?(cookies[:remember_token]) # if the remember token is matched with remember digest in model
	  	  log_in user # why log in user? since user was logged in when session was created
	  	  @current_user = user
	  	end
	  end
	end

	def logged_in?
	  !current_user.nil?
	end

	# forgets a persistent session.
	def forget(user)
	  user.forget #update the remember digest with nil
	  cookies.delete(:user_id)
	  cookies.delete(:remember_token)
	end

	# Logs out the current user.
	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end

	# Redirects to stored location (or to the default.
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url) # why delete?
	end

	# Stores the URL trying to be accessed.
	# puts the requested URL in the session variable under the key :forwarding_url only for a GET request.
	def store_location
		session[:forwarding_url] = request.url if request.get? # why if?
	end
end
