require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should not have empty username name email password" do
    user = User.new 
    assert user.invalid?, "invalid?"
    assert user.errors[:username].any?, "username"
    assert user.errors[:name].any?, "name"
    assert user.errors[:email].any?, "email"
    assert user.errors[:password].any?, "password"
    assert !user.save
  end

  test "should not have duplicate usernames email" do
    user = User.new(users(:jd).attributes.slice("username", "email"))
    assert user.invalid?, "invalid?"
    assert user.errors[:username].any?, "username"
    assert_equal "has already been taken", user.errors.messages[:username][0], "username"
    assert user.errors[:email].any?, "email"
    assert_equal "has already been taken", user.errors.messages[:email][0], "email"
    assert !user.save
  end

  test "usernames email uniqueness should be case-insensitive" do
    user = User.new(users(:jd).attributes.slice("username", "email").each { |a, v| v.upcase! })
    assert user.invalid?, "invalid?"
    assert user.errors[:username].any?, "username"
    assert_equal "has already been taken", user.errors.messages[:username][0], "username"
    assert user.errors[:email].any?, "email"
    assert_equal "has already been taken", user.errors.messages[:email][0], "email"
    assert !user.save
  end
  
  test "avatar should be less than 100 Kb" do
    user = users(:jd)
    user.avatar = File.open(Rails.root.to_s + "/test/fixtures/big_photo.jpg")
    assert user.invalid?, "invalid?"
    assert user.errors[:avatar_file_size].any?, "avatar_file_size"
    assert_equal "must be less than 100 Kb", user.errors.messages[:avatar_file_size][0], "avatar_file_size"
    assert !user.save
  end
  
  test "avatar should be jpeg, png, or gif" do
    user = users(:jd)
    user.avatar = File.open(Rails.root.to_s + "/test/fixtures/users.yml")
    assert user.invalid?, "invalid?"
    assert user.errors[:avatar_content_type].any?, "avatar_content_type"
    assert_equal "is invalid", user.errors.messages[:avatar_content_type][0], "avatar_content_type"
    assert !user.save
  end
  
  test "may have following" do
    jd     = users(:jd)
    sxcine = users(:sxcine)
    other  = users(:other)
    assert jd.following.include?(sxcine)
    assert !jd.following.include?(other)
  end
  
  test "may have followers" do
    jd     = users(:jd)
    sxcine = users(:sxcine)
    other  = users(:other)
    assert sxcine.followers.include?(jd)
    assert !sxcine.followers.include?(other)
  end
  
  # search
  test "should return search results" do
    results = User.search("j")
    assert results.include?(users(:jd))
  end
  test "should return no results if sent no search text" do
    results = User.search
    assert_equal 0, results.size
  end
  test "search results should not include sent user" do
    jd = users(:jd)
    results = User.search("j", jd)
    assert !results.include?(jd)
  end
  test "should not search in the server part of emails" do
    results = User.search("local.com")
    assert_equal 0, results.size
  end
  test "should search user part of an email addresses" do
    results = User.search("jd@local.com")
    assert results.include?(users(:jd))
  end
  test "should not search domain part of an email addresses" do
    results = User.search("@local.com")
    assert_equal 0, results.size
  end
  
end
