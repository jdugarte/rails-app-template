class HomeController < ApplicationController

  def index
  end
  def home
  end
  
  def search
    @search_in = params[:search_in]
    if @search_in == "users"
      @users = User.search(params[:search], current_user)
    end
  end
  
end
