# frozen_string_literal: true

# CurrentGameChannel extends Turbo::StreamsChannel (from the turbo-rails gem;
# See: https://github.com/hotwired/turbo-rails/tree/v2.0.6)
#
# This is an attempt at keeping a count of the number of current subscribers to
# the :current_game stream, which shall be the only stream on this channel.
#
# NOTE:
#  - This is buggy... at least in the development environment. Reconsider once
#    we get to production. Either way, it may be better than nothing.
class CurrentGameChannel < Turbo::StreamsChannel
  # Override Turbo::StreamsChannel#subscribed to add #on_subscribe logic.
  def subscribed
    if (stream_name = verified_stream_name_from_params)
      stream_from(stream_name)

      on_subscribe # <- CUSTOM CODE
    else
      reject
    end
  end

  def unsubscribed
    on_unsubscribe
  end

  private

  def on_subscribe
    DutyRoster.increment
    Rails.logger.info {
      " -> Incrementing DutyRoster. New count: #{DutyRoster.count.inspect}"
    }
  end

  def on_unsubscribe
    DutyRoster.decrement
    Rails.logger.info {
      " -> Decrementing DutyRoster. New count: #{DutyRoster.count.inspect}"
    }
  end
end
