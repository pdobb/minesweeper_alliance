# frozen_string_literal: true

# WarRoomChannel extends Turbo::StreamsChannel (from the turbo-rails gem:
# https://github.com/hotwired/turbo-rails/blob/main/app/channels/turbo/streams_channel.rb)
#
# The primary need for this custom channel is to keep track of current
# connections to the War Room.
#
# NOTE: Subscription tracking for web sockets / streams are (very) often
# unreliable. We must take pains to attenuate this unreliability, while boosting
# what we can rely on. See: {FleetTracker}.
class WarRoomChannel < Turbo::StreamsChannel
  STREAM_NAME = "war_room"

  def self.broadcast_refresh = broadcast_refresh_to(STREAM_NAME)

  def self.broadcast_append(...) = broadcast_append_to(STREAM_NAME, ...)
  def self.broadcast_remove(...) = broadcast_remove_to(STREAM_NAME, ...)
  def self.broadcast_replace(...) = broadcast_replace_to(STREAM_NAME, ...)
  def self.broadcast_update(...) = broadcast_update_to(STREAM_NAME, ...)

  # Broadcast a custom-built Array of `<turbo-stream>...</turbo-stream>`
  # element(s).
  def self.broadcast(content, ...)
    ActionCable.server.broadcast(STREAM_NAME, content, ...)
  end

  # Override Turbo::StreamsChannel#subscribed to add #on_subscribe logic.
  def subscribed
    if stream_name && current_user?
      stream_from(stream_name)
      on_subscribe
    else
      reject
    end
  end

  def unsubscribed
    on_unsubscribe if current_user?
  end

  private

  def stream_name = verified_stream_name_from_params
  def current_user? = !!current_user

  def on_subscribe
    FleetTracker.add!(current_user_token) if current_user.participant?
  end

  def on_unsubscribe
    FleetTracker.expire!(current_user_token) if current_user.participant?
  end

  def current_user_token = current_user.token
end
