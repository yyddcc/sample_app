# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
  	user = User.first
  	user.activation_token = User.new_token # needed by account_activation.text.erb in views
    # the activation in user.rb doesn't work coz it only fires up when user sign up.
    UserMailer.account_activation(user) # defined in user_mailer.rb
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end
end
