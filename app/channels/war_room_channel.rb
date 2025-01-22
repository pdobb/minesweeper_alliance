# frozen_string_literal: true

# WarRoomChannel extends Turbo::StreamsChannel (from the turbo-rails gem;
# See: https://github.com/hotwired/turbo-rails/tree/v2.0.6)
#
# This is an attempt at keeping a count of the number of current subscribers to
# the :current_game stream, which shall be the only stream on this channel.
#
# NOTE: Subscription tracking for web sockets / streams are (very) often
# unreliable. We must take pains to attenuate this unreliability, while boosting
# what we can rely on.
class WarRoomChannel < Turbo::StreamsChannel
  STREAM_NAME = :current_game

  def self.broadcast_refresh = broadcast_refresh_to(STREAM_NAME)

  def self.broadcast_replace(...) = broadcast_replace_to(STREAM_NAME, ...)
  def self.broadcast_update(...) = broadcast_update_to(STREAM_NAME, ...)

  def self.broadcast_versioned_replace(target:, **)
    broadcast_action_to(STREAM_NAME, action: :versioned_replace, target:, **)
  end

  # Broadcast a custom-built Array of `<turbo-stream>...</turbo-stream>`
  # element(s).
  def self.broadcast(content, ...)
    content = Array.wrap(content).join
    ActionCable.server.broadcast(STREAM_NAME, content, ...)
  end

  # Override Turbo::StreamsChannel#subscribed to add #on_subscribe logic.
  def subscribed
    if stream_name && current_user_token?
      stream_from(stream_name)
      on_subscribe
    else
      reject
    end
  end

  def unsubscribed
    on_unsubscribe if current_user_token?
  end

  private

  def stream_name = verified_stream_name_from_params
  def current_user_token? = !!current_user_token

  def on_subscribe
    FleetTracker.add!(token: current_user_token)
  end

  def on_unsubscribe
    FleetTracker.remove!(token: current_user_token)
  end
end
