require 'test_helper'

class FriendsControllerTest < ActionController::TestCase

  setup do
    @jd     = users(:jd)
    @sxcine = users(:sxcine)
    @other  = users(:other)
  end
  
  # create
  test "should add friend" do
    sign_in @jd
    post :create, id: @other.id
    assert @jd.following.include?(@other)
    assert @other.followers.include?(@jd)
    assert_redirected_to profile_path(@other.username)
  end
  test "should remove friend" do
    sign_in @jd
    post :create, id: @sxcine.id
    assert !@jd.following.include?(@sxcine)
    assert !@sxcine.followers.include?(@jd)
    assert_redirected_to profile_path(@sxcine.username)
  end
  test "should not add/remove while not signed in" do
    post :create, id: @other.id
    assert !@jd.following.include?(@other)
    assert !@other.followers.include?(@jd)
    assert_redirected_to new_user_session_path
  end
  test "should redirect to root if user doesn't exists" do
    sign_in @jd
    post :create, id: 999
    assert_redirected_to root_path
  end
  
end
