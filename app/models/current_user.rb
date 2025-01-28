# frozen_string_literal: true

# CurrentUser is a Service Object that is responsible for look-up/creation of
# {User} records.
# - Lookup is performed via the "User Token" stored in
#   `cookies.signed[CurrentUser::COOKIE]`.
# - Creation of a new {User} record generates a "User Token", which is actually
#   just the GUID generated by the DB ({User#id}). Which is then "permanently"
#   stored into `cookies.signed[CurrentUser::COOKIE]` for future lookup.
class CurrentUser
  COOKIE = :user_token

  include CallMethodBehaviors

  def initialize(context:)
    @context = context
  end

  def call
    MigrateToSignedUserTokenCookie.(context:) # TODO: Remove when site != beta.

    if stored_user_token?
      find || create
    else
      create
    end
  end

  private

  attr_reader :context

  def cookies = context.cookies

  def find
    User.for_id(stored_user_token).take.tap { |user|
      # TODO: Remove when site != beta.
      BackfillRequestData.(user:, context:) if user
    }
  end

  def stored_user_token? = stored_user_token.present?

  def stored_user_token
    @stored_user_token ||= cookies.signed[COOKIE]
  end

  def create
    User.create(user_agent:).tap { |new_user|
      store_user_token(value: new_user.token)
    }
  end

  def user_agent = context.user_agent

  def store_user_token(value:)
    context.store_signed_http_cookie(COOKIE, value:)
  end

  # CurrentUser::MigrateToSignedUserTokenCookie is a temporary service object
  # for migrating existing users over from unsigned to signed "user_token"
  # cookie storage.
  #
  # TODO: Remove when site != beta.
  class MigrateToSignedUserTokenCookie
    include CallMethodBehaviors

    def initialize(context:)
      @context = context
    end

    # :reek:TooManyStatements
    def call
      return if new_signed_user_token?
      return unless old_unsigned_user_token?

      user_token = old_user_token
      delete_old_cookie
      store_new_signed_cookie(value: user_token)
    end

    private

    def new_signed_user_token? = cookies.signed[COOKIE].present?
    def old_unsigned_user_token? = old_user_token.present?

    def old_user_token = @old_user_token ||= cookies[COOKIE]

    def delete_old_cookie
      cookies.delete(COOKIE)
    end

    def store_new_signed_cookie(value:)
      context.store_signed_http_cookie(COOKIE, value:)
    end

    attr_reader :context

    def cookies = context.cookies
  end

  # CurrentUser::BackfillRequestData is a temporary service object
  # for backfilling request data into existing {User}s, as they come back to
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
