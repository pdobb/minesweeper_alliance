# frozen_string_literal: true

# User::Update is responsible for {User} attribute updates.
class User::Update
  def self.call(...) = new(...).call

  def initialize(user, attributes:)
    @user = user
    @attributes = attributes
  end

  def call
    user.attributes = attributes
    user.user_update_transactions.build(change_set:) if username_changed?
    user.save
  end

  private

  attr_reader :user,
              :attributes

  def change_set
    { username: username_change_set }
  end

  def username_change_set
    { old: old_username, new: new_username }
  end

  def username_changed? = user.username_changed?
  def old_username = user.username_was
  def new_username = user.username
end
