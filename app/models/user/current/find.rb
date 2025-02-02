# frozen_string_literal: true

# User::Current::Find handles "Current {User}" lookup. Else, if not found, a
# {Guest} object is returned instead.
#
# Lookup is performed via the "User Token" stored in the cookie identified by
# {User::Current::COOKIE}.
class User::Current::Find
  include CallMethodBehaviors

  def initialize(context:) = @context = context

  def call
    user = find_user if stored_user_token?
    user || Guest::Current.(context:)
  end

  private

  attr_reader :context

  def cookies = context.cookies

  def stored_user_token? = stored_user_token.present?
  def find_user = User.for_token(stored_user_token).take

  def stored_user_token
    @stored_user_token ||= cookies.signed[User::Current::COOKIE]
  end
end
