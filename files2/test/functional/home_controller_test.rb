require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  
  setup do
    @user = users(:jd)
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
