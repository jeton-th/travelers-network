# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'associated posts should be destroyed' do
    @user.save
    @user.posts.create!(content: 'Lorem ipsum')
    assert_difference 'Post.count', -1 do
      @user.destroy
    end
  end

  test 'associated request should be destroyed' do
    user1 = users(:user1)
    user2 = users(:user2)
    user1.sent_requests.create(receiver_id: user2.id)
    assert_difference 'Request.count', -1 do
      user1.destroy
    end
  end

  test 'should send a request' do
    user1 = users(:user1)
    user2 = users(:user2)
    assert_not user1.receivers.include?(user2)
    assert_not user2.senders.include?(user1)
    user1.sent_requests.create(receiver_id: user2.id)
    assert user1.receivers.include?(user2)
    assert user2.senders.include?(user1)
  end

  test 'should have a friend' do
    user1 = users(:user1)
    user2 = users(:user2)
    assert_not user1.friends.include?(user2)
    assert_not user2.friends.include?(user1)
    user1.friendships.create(friend_id: user2.id)
    assert user1.friends.include?(user2)
    assert user2.friends.include?(user1)
  end
end
