# frozen_string_literal: true

# Games::Current::CreateParticipant ...
# - Creates the "Current {User}" to which this Cell Action will be associated
# - Creates an active {ParticipantTransaction} between the new {User} and the
#   passed-in {Game}
class Games::Current::CreateParticipant
  def self.call(...) = new(...).call

  def initialize(game:, context:)
    @game = game
    @context = context
  end

  def call
    return if current_user.participant?

    context.current_user_will_change

    User.transaction do
      User::Current::Create.(context: CreateUserContext.new(context))
      ParticipantTransaction.create_active_between(user: current_user, game:)
    end

    FleetTracker.add!(current_user.token)
  end

  private

  attr_reader :game,
              :context

  def current_user = context.current_user
  def cookies = context.__send__(:cookies)

  # Games::Current::CreateParticipant::CreateUserContext services the needs of
  # {User::Current::Create}.
  class CreateUserContext
    def initialize(context) = @context = context
    def layout = context.layout

    def user_agent = layout.user_agent
    def store_signed_cookie(...) = layout.store_signed_cookie(...)
    def delete_cookie(...) = layout.cookies.delete(...)

    private

    attr_reader :context
  end
end
