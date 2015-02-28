require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name:"Pero Peric", email:"peroperic@gmail.com", password:"foobar", password_confirmation:"foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.name = " "
    assert_not @user.valid?
  end
  
  test "should not be too long" do
    @user.name = "a"*51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.name = "a"*244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid adresses" do
    invalid_adresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_adresses.each do |invalid_adr|
      @user.email = invalid_adr
      assert_not @user.valid?, "#{invalid_adr.inspect} should be invalid"
    end
  end
  
  test "email adresses should be uniue" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "emails downcase" do
    mixed_case_email = "Foo@ExamPLE.Com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    antonio = users(:antonio)
    archer  = users(:archer)
    assert_not antonio.following?(archer)
    antonio.follow(archer)
    assert antonio.following?(archer)
    assert archer.followers.include?(antonio)
    antonio.unfollow(archer)
    assert_not antonio.following?(archer)
  end

  test "feed should have the right posts" do
    antonio = users(:antonio)
    archer = users(:archer)
    lana = users(:lana)
    #posts from followed user
    lana.microposts.each do |post_following|
      assert antonio.feed.include?(post_following)
    end
    #posts from self
    antonio.microposts.each do |post_self|
      assert antonio.feed.include?(post_self)
    end
    #posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not antonio.feed.include?(post_unfollowed)
    end
  end
end
