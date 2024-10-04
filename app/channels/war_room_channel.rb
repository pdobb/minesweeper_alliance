# frozen_string_literal: true

# WarRoomChannel extends Turbo::StreamsChannel (from the turbo-rails gem;
# See: https://github.com/hotwired/turbo-rails/tree/v2.0.6)
#
# This is an attempt at keeping a count of the number of current subscribers to
# the :current_game stream, which shall be the only stream on this channel.
#
# NOTE:
#  - This is buggy... at least in the development environment. Reconsider once
#    we get to production. Either way, it may be better than nothing.
class WarRoomChannel < Turbo::StreamsChannel
  # Override Turbo::StreamsChannel#subscribed to add #on_subscribe logic.
  def subscribed
    if stream_name && current_user_token?
      stream_from(stream_name)
      on_subscribe
    else
      reject and log_rejection_event(stream_name)
    end
  end

  def unsubscribed
    on_unsubscribe if current_user_token?
  end

  private

  def stream_name = verified_stream_name_from_params
  def current_user_token? = !!current_user_token

  def log_rejection_event(stream_name)
    Rails.logger.info do
      " !¡ WarRoomChannel#reject "\
        "stream_name=#{stream_name.inspect}), "\
        "current_user_token=#{current_user_token.inspect}"
    end
  end

  def on_subscribe
    log_subscription_event(__method__) do
      DutyRoster.add(current_user_token)
    end

    broadcast_subscription_update
  end

  def on_unsubscribe
    log_subscription_event(__method__) do
      DutyRoster.remove(current_user_token)
    end

    broadcast_subscription_update
  end

  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  def log_subscription_event(method_name)
    event = method_name.to_s[3..].capitalize

    before = DutyRoster.participants.to_a
    result = yield
    after = DutyRoster.participants.to_a

    Rails.logger.info do
      " -> WarRoomChannel/#{event} "\
        "current_user_token=#{current_user_token.inspect}) :: "\
        "DutyRoster: #{before.inspect} -> #{after.inspect}"
    end

    result
  end

  def broadcast_subscription_update
    Games::Show.broadcast_players_count_update(
      stream_name:, count: DutyRoster.count)
  end
end
