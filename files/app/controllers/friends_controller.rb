class FriendsController < ApplicationController

  before_filter :authenticate_user_with_ajax!

  def create
    friend = User.find params[:id]
    if current_user.following.include? friend
      current_user.following.delete friend
    else
      current_user.following << friend
    end
    redirect_to profile_path(friend.username)
  end
  
end
