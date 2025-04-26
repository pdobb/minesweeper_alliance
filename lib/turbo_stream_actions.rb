# frozen_string_literal: true

# TurboStreamActions collects Turbo Stream actions intended for response,
# broadcast, or both. Collections are {FlatArray}s.
class TurboStreamActions
  def initialize
    @hash = {
      response: Response.new,
      broadcast: Broadcast.new,
    }
  end

  def <<(value)
    response << value
    broadcast << value
  end

  def response = hash.fetch(:response)
  def broadcast = hash.fetch(:broadcast)

  private

  attr_reader :hash

  # rubocop:disable Lint/UselessConstantScoping

  # TurboStreamActions::Response collects response actions into a {FlatArray}.
  Response = Class.new(FlatArray)

  # TurboStreamActions::Broadcast collects broadcast actions into a {FlatArray}.
  Broadcast = Class.new(FlatArray)

  # rubocop:enable Lint/UselessConstantScoping
end
