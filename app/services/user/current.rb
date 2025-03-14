# frozen_string_literal: true

# User::Current
# 1. Provides high-level "Current User"-related utility methods.
# 2. Holds namespace-level items for {User::Current::Find} and
#    {User::Current::Create}.
module User::Current
  COOKIE = "user_token"

  def self.dev?(user)
    user.token.in?(dev_tokens)
  end

  def self.dev_tokens
    @dev_tokens ||= User.is_dev.ids
  end
  private_class_method :dev_tokens
end
