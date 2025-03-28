# frozen_string_literal: true

# Responder wraps up the request cycle of a controller by
# 1. Broadcasting, and
# 2. Responding with
# ... the given `html` entries (Turbo Stream Templates).
class WarRoom::Responder
  def self.call(...) = new(...).call

  # @param trubo_stream_actions [TurboStreamActions]
  def initialize(turbo_stream_actions:, context:)
    @turbo_stream_actions = turbo_stream_actions
    @context = context
  end

  def call
    WarRoomChannel.broadcast(broadcast_actions)
    respond_with(response_actions)
  end

  private

  attr_reader :turbo_stream_actions,
              :context

  def broadcast_actions
    turbo_stream_actions.broadcast.join
  end

  def response_actions
    turbo_stream_actions.response.join
  end

  def respond_with(html)
    respond_to do |format|
      format.html { redirect_to(Router.root_path) }
      format.turbo_stream { render(turbo_stream: html) }
    end
  end

  def respond_to(...) = context.respond_to(...)
  def redirect_to(...) = context.redirect_to(...)
  def render(...) = context.render(...)
end
