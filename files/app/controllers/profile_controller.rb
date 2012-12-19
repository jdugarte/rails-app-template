class ProfileController < ApplicationController

  before_filter :authenticate_user!, :except => :show
  
  def show
    @user = User.find_by_username params[:username]
    if @user.nil?
      flash[:error] = t('profile.show.user_not_found')
      redirect_to :root
    end
  end

  def edit
    @user = User.find current_user.id
    @password = @user.clone
  end

  def update
    @user = User.find current_user.id
    @password = @user.clone
    respond_to do |format|
      if @user.update_attributes(params[:user].slice(:username, :name, :email, :avatar))
        format.html { redirect_to profile_path(@user.username), notice: t('profile.edit.edited_successfully') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def change_password
    @user = User.find current_user.id
    @password = @user.clone
    respond_to do |format|
      if @password.update_with_password(params[:user].slice(:current_password, :password, :password_confirmation))
        sign_in @password, :bypass => true
        format.html { redirect_to profile_path(@password.username), notice: t('profile.edit.password_updated_successfully') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @password.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
