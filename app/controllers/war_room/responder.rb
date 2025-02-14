# frozen_string_literal: true

# Responder wraps up the request cycle of a controller by
# 1. Broadcasting, and
# 2. Responding with
# ... the given `html` (joined Turbo Stream Templates)
class WarRoom::Responder
  def initialize(context:)
    @context = context
  end

  def call(turbo_stream_actions:)
    html = Array.wrap(turbo_stream_actions).join
    WarRoomChannel.broadcast(html)
    respond_with(html)
  end

  private

  attr_reader :context

  def respond_to(...) = context.respond_to(...)
  def redirect_to(...) = context.redirect_to(...)
  def render(...) = context.render(...)

  def respond_with(html)
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.turbo_stream { render(turbo_stream: html) }
    end
  end
end
