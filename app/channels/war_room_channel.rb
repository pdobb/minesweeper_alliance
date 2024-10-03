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
      log_rejection_event(stream_name)
      reject
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
      " !¡ WarRoomChannel#reject(#{stream_name}) :: "\
        "current_user_token=#{current_user_token.inspect}"
    end
  end

  def on_subscribe
    count =
      log_subscription_event(__method__) {
        DutyRoster.add(current_user_token)
      }.size

    broadcast_subscription_count_update(count:)
  end

  def on_unsubscribe
    count =
      log_subscription_event(__method__) {
        DutyRoster.remove(current_user_token)
      }.size

    broadcast_subscription_count_update(count:)
  end

  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  def log_subscription_event(method_name)
    before = DutyRoster.participants
    result = yield
    after = DutyRoster.participants

    Rails.logger.info do
      " -> WarRoomChannel##{method_name} "\
        "(current_user_token=#{current_user_token.inspect}) :: "\
        "DutyRoster: #{before.inspect} -> #{after.inspect}"
    end

    result
  end

  def broadcast_subscription_count_update(count:)
    Games::Show.broadcast_players_count_update(stream_name:, count:)
  end
end
