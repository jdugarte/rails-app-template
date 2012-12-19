require 'test_helper'

class HomeControllerMobileTest < ActionController::TestCase
  tests HomeController
  
  setup do
    HomeController.any_instance.expects(:is_mobile?).at_least_once.returns(true)
  end

  # index
  test "should get index" do
    get :index
    assert_response :success
  end
  
  # search users
  test "should get user search results while not signed in" do
    get :search, search_in: "users", search: "j"
    assert_response :success
    assert_not_nil assigns(:users)
    assert_equal 1, assigns(:users).size
    assert assigns(:users).include?(users(:jd))
    assert !assigns(:users).include?(users(:other))
  end
  test "should get user search results while signed in" do
    sign_in users(:jd)
    get :search, search_in: "users", search: "x"
    assert_response :success
    assert_not_nil assigns(:users)
    assert_equal 1, assigns(:users).size
    assert assigns(:users).include?(users(:sxcine))
    assert !assigns(:users).include?(users(:other))
  end
  test "user results should not include myself" do
    sign_in users(:jd)
    get :search, search_in: "users", search: "j"
    assert_response :success
    assert_not_nil assigns(:users)
    assert_equal 0, assigns(:users).size
    assert !assigns(:users).include?(users(:jd))
  end
  test "should get empty user search results" do
    get :search, search_in: "users"
    assert_response :success
    assert_not_nil assigns(:users)
    assert_equal [], assigns(:users)
  end

end
