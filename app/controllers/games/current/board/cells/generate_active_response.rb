# frozen_string_literal: true

# Games::Current::Board::Cells::GenerateActiveResponse generates and bundles
# together an "active response"--one requiring a participant ({User}). If there
# is no Current User, then one is created (via
# {Games::Current::CreateParticipant}) and Turbo Stream Actions for that event
# are generated and bundled into the response. The fully generated response is
# then handed over to {WarRoom::Responder} for broadcast/delivery.
class Games::Current::Board::Cells::GenerateActiveResponse
  include CallMethodBehaviors

  def initialize(context:)
    @context = context
    @turbo_stream_actions = FlatArray.new

    require_participant
  end

  def <<(cells)
    turbo_stream_actions <<
      Cell::TurboStream::Morph.wrap_and_call(cells, turbo_stream:)
  end

  def call
    turbo_stream_actions << yield if block_given?

    generate_response
    activate_participant
  end

  private

  attr_reader :context,
              :turbo_stream_actions

  def game = context.__send__(:game)
  def current_user = context.current_user
  def current_user_token = current_user.token
  def turbo_stream = context.__send__(:turbo_stream)

  def require_participant
    return if current_user.participant?

    Games::Current::CreateParticipant.(game:, context:)
    generate_user_nav_turbo_stream_update_action
  end

  def generate_user_nav_turbo_stream_update_action
    nav = CurrentUser::Nav.new(user: current_user)

    turbo_stream_actions <<
      turbo_stream.replace(
        nav.turbo_target,
        method: :morph,
        partial: "current_user/nav",
        locals: { nav: })
  end

  def activate_participant
    FleetTracker.activate!(current_user_token)
  end

  def generate_response
    WarRoom::Responder.new(context:).(turbo_stream_actions:)
  end
end
