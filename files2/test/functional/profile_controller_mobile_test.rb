require 'test_helper'

class ProfileControllerMobileTest < ActionController::TestCase
  tests ProfileController

  setup do
    @user = users(:jd)
    ProfileController.any_instance.expects(:is_mobile?).at_least_once.returns(true)
  end
  
  # show
  test "should show profile while signed in" do
    sign_in @user
    get :show, username: users(:sxcine).username
    assert_response :success
  end
  test "should not show profile while not signed in" do
    get :show, username: @user.username
    assert_redirected_to new_user_session_path
  end
  test "should show error when user doesn't exist" do
    sign_in @user
    get :show, username: "xxx"
    assert_redirected_to root_path
  end
  
  # edit
  test "should get edit" do
    sign_in @user
    get :edit
    assert_response :success
  end
  test "should not get edit while not signed in" do
    get :edit
    assert_redirected_to new_user_session_path
  end

  # update
  test "should update profile" do
    sign_in @user
    put :update, user: { username: "xxx", name: "XXX", email: "xxx@local.com" }
    assert_redirected_to profile_path(assigns(:user).username)
  end
  test "should not update profile while not signed in" do
    put :update, user: { name: @user.name }
    assert_redirected_to new_user_session_path
  end
  test "should go back to edit form when there is an error in user data" do
    sign_in @user
    put :update, user: { username: "", name: "XXX", email: "xxx@local.com" }
    assert_template("edit")
  end

  # change password
  test "should change password" do
    sign_in @user
    put :change_password, user: { current_password: "123123", password: "123456", password_confirmation: "123456" }
    assert_redirected_to profile_path(assigns(:user).username)
  end
  test "should not change password while not signed in" do
    put :change_password, user: { current_password: "123123" }
    assert_redirected_to new_user_session_path
  end
  test "should go back to edit form when there is an error in password" do
    sign_in @user
    put :change_password, user: { current_password: "123123", password: "123456", password_confirmation: "123457" }
    assert_template("edit")
  end
  
end
