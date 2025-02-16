# frozen_string_literal: true

# Games::Current::Board::Cells::GeneratePassiveResponse generates and bundles
# together a "passive response"--one that doesn't require a participant
# ({User}). The generated response is then handed over to {WarRoom::Responder}
# for broadcast/delivery.
class Games::Current::Board::Cells::GeneratePassiveResponse
  include CallMethodBehaviors

  def initialize(context:)
    @context = context
    @turbo_stream_actions = FlatArray.new
  end

  def <<(cells)
    turbo_stream_actions <<
      Cell::TurboStream::Morph.wrap_and_call(cells, turbo_stream:)
  end

  def call
    generate_response
  end

  private

  attr_reader :context,
              :turbo_stream_actions

  def turbo_stream = context.__send__(:turbo_stream)

  def generate_response
    WarRoom::Responder.new(context:).(turbo_stream_actions:)
  end
end
