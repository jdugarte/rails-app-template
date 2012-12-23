require 'test_helper'

class HomeControllerMobileTest < ActionController::TestCase
  tests HomeController
  
  setup do
    @user = users(:jd)
    HomeController.any_instance.expects(:is_mobile?).at_least_once.returns(true)
  end

  # index
  test "should get index while signed in" do
    sign_in @user
    get :index
    assert_response :success
  end
  test "should not get index while not signed in" do
    get :index
    assert_redirected_to new_user_session_path
  end
  
end
