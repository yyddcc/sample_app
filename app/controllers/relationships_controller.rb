class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
  	@user = User.find(params[:followed_id]) # Hidden tag in _follow_.html.erb
  	current_user.follow(@user) # defined in user,rb
  	respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
  	@user = Relationship.find(params[:id]).followed # ?
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
