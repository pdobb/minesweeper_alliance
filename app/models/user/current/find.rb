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
    MigrateFromOldUserTokenCookie.(context:)

    user = do_find if stored_user_token?
    user || Guest::Current.(context:)
  end

  private

  attr_reader :context

  def cookies = context.cookies

  def do_find
    User.for_id(stored_user_token).take.tap { |user|
      # TODO: Remove when site != beta.
      BackfillRequestData.(user:, context:) if user
    }
  end

  def stored_user_token? = stored_user_token.present?

  def stored_user_token
    @stored_user_token ||= cookies.signed[User::Current::COOKIE]
  end

  # User::Current::Find::MigrateFromOldUserTokenCookie migrates old users over
  # from the "user_token" cookie to the new "user_token-v2" cookie for
  # identifying the current {User}. Really old users will have an unsigned
  # cookie.
  class MigrateFromOldUserTokenCookie
    OLD_COOKIE = "user_token"

    include CallMethodBehaviors

    def initialize(context:)
      @context = context
    end

    # :reek:TooManyStatements
    def call
      return unless old_user_token?

      if new_user_token?
        delete_old_cookie
        return
      end

      user_token = old_user_token
      store_new_signed_cookie(value: user_token)
      delete_old_cookie
    end

    private

    def new_user_token? = cookies.signed[User::Current::COOKIE].present?
    def old_user_token? = old_user_token.present?

    def old_user_token
      @old_user_token ||= cookies.signed[OLD_COOKIE] || cookies[OLD_COOKIE]
    end

    def store_new_signed_cookie(value:)
      context.store_signed_cookie(User::Current::COOKIE, value:)
    end

    def delete_old_cookie
      cookies.delete(OLD_COOKIE)
    end

    attr_reader :context

    def cookies = context.cookies
  end

  # User::Current::Find::BackfillRequestData is a temporary service object
  # for back-filling request data into existing {User}s, as they come back to
  # visit the site.
  #
  # TODO: Remove when site != beta.
  class BackfillRequestData
    include CallMethodBehaviors

    def initialize(user:, context:)
      @user = user
      @context = context
    end

    # :reek:TooManyStatements
    def call
      return if user.user_agent?

      user.update(user_agent:)
    end

    private

    attr_reader :user,
                :context

    def user_agent = context.user_agent
  end
end
