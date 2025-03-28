# frozen_string_literal: true

# User::Authentication identifies and restores a {User} "session". i.e. the
# "Current {User}" pointed to by their browser cookie. This allows for e.g.
# changing browsers--by making a bookmark of the "permanent link" that contains
# their {User#authentication_token}.
class User::Authentication
  def self.call(...) = new(...).call

  def initialize(token:, context:)
    @token = token
    @context = context
  end

  def call
    return unless (user = find_user)

    store_signed_cookie(value: user.token)
    user
  end

  private

  attr_reader :token,
              :context

  def cookies = context.cookies

  def find_user
    User.for_authentication_token(token).take
  end

  def store_signed_cookie(value:)
    context.store_signed_cookie(User::Current::COOKIE, value:)
  end
end
