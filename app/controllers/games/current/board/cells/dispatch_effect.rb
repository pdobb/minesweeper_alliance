# frozen_string_literal: true

# Games::Current::Board::Cells::DispatchEffect:
# 1. Yields a {Games::Current::Board::Cells::DispatchEffect::Dispatch} object
#    for bundling action updates together,
# 2. Builds a primary Action based on the effect, and
# 3. Hands over the bundled Actions to {WarRoom::Responder} for
#    broadcast/delivery.
#
# DispatchEffect is meant for handling passive Cell Actions, which don't affect
# the {Game} play history. For active Cell Actions, use
# {Games::Current::Board::Cells::DispatchAction} instead.
class Games::Current::Board::Cells::DispatchEffect
  def initialize(context:)
    @context = context
    @turbo_stream_actions = FlatArray.new
  end

  def call
    yield(Dispatch.new(turbo_stream_actions:, context:))

    generate_response
  end

  private

  attr_reader :context,
              :turbo_stream_actions

  def turbo_stream = context.__send__(:turbo_stream)

  def generate_response
    WarRoom::Responder.new(context:).(turbo_stream_actions:)
  end

  # Games::Current::Board::Cells::DispatchEffect::Dispatch is a yielded object
  # the collects / bundles together the Turbo Stream Actions produced by the
  # actual Cell Action being performed by the Controller.
  class Dispatch
    include CallMethodBehaviors
    include Games::Current::Board::Cells::DispatchBehaviors

    # :reek:DuplicateMethodCall
    def initialize(turbo_stream_actions:, context:)
      @turbo_stream_actions = turbo_stream_actions
      @context = context
    end

    def call
      generate_game_update_action
      turbo_stream_actions << yield if block_given?
    end

    private

    attr_reader :turbo_stream_actions,
                :context

    def board = context.__send__(:board)
    def render_to_string(...) = context.render_to_string(...)

    def turbo_stream = context.__send__(:turbo_stream)
  end
end
