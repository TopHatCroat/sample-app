require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:antonio)
    log_in_as(@user)  
  end

  test "unsuccessful edit" do  
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: {name: "", email: "foo@infalid", password:"foo", password_confirmation:"bar"}
    assert_template 'users/edit'

  end

  test "succsesful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo bar"
    email = "foo@bar.com"
    patch user_path(@user), user: {name: name, email: email, password: "", password_confirmation: ""}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to user_path(@user) #should be edit_user_path
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "foobar",
                                    password_confirmation: "foobar" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name,  name
    assert_equal @user.email, email
  end
end

