# frozen_string_literal: true

# Guest::Current builds a new {Guest} object based on the presence of a
# "guest_token" cookie. If the cookie doesn't exist, it creates one with a newly
# generated value.
#
# @see Guest
class Guest::Current
  COOKIE = "guest_token"
  COOKIE_EXPIRATION_PERIOD = 2.weeks

  def self.call(...) = new(...).call

  def initialize(context:) = @context = context

  def call
    generate_and_store_new_guest_token unless stored_guest_token?

    Guest.new(token: stored_guest_token)
  end

  private

  attr_reader :context

  def cookies = context.cookies

  def stored_guest_token? = stored_guest_token.present?
  def stored_guest_token = @stored_guest_token ||= cookies[COOKIE]

  def generate_and_store_new_guest_token
    store_guest_token(generate_new_guest_token)
  end

  def generate_new_guest_token
    [
      Guest::TOKEN_SENTINEL,
      SecureRandom.alphanumeric(User::TRUNCATED_TOKENS_LENGTH),
    ].join
  end

  def store_guest_token(value)
    cookies[COOKIE] = {
      value:,
      expires: COOKIE_EXPIRATION_PERIOD.from_now,
      secure: App.production?,
    }
  end
end
