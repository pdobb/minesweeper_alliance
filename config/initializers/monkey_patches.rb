# frozen_string_literal: true

# This is a monkey patch of Turbo::StreamsChannel from the turbo-rails gem.
# Code from v2.0.6: https://github.com/hotwired/turbo-rails/tree/v2.0.6
# We're attempting to keep a count of the number of current subscribers to the
# Turbo stream.
#
# NOTE:
#  - This is buggy... at least in the development environment. I'm guessing that
#    code changes and reloading are affecting the counts here. Reconsider once
#    we get to production. Either way, it may be better than nothing.
class Turbo::StreamsChannel < ActionCable::Channel::Base
  extend Turbo::Streams::Broadcasts
  extend Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    if (stream_name = verified_stream_name_from_params)
      stream_from(stream_name)

      on_subscribe # <- CUSTOM CODE
    else
      reject
    end
  end

  # CUSTOM CODE:

  # :reek:UtilityFunction
  def unsubscribed
    on_unsubscribe
  end

  private

  def on_subscribe
    return if verified_stream_name_from_params != "current_game"

    DutyRoster.increment
    Rails.logger.info {
      " -> Incrementing DutyRoster. New count: #{DutyRoster.count.inspect}"
    }
  end

  def on_unsubscribe
    return if verified_stream_name_from_params != "current_game"

    DutyRoster.decrement
    Rails.logger.info {
      " -> Decrementing DutyRoster. New count: #{DutyRoster.count.inspect}"
    }
  end
end
