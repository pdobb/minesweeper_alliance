# frozen_string_literal: true

# DutyRoster represents the number of Minesweepers (players / allies) currently
# reporting for duty--or at least *viewing* the Game Board.
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
module DutyRoster
  def self.participants
    cache.fetch(:participants) { [] }
  end

  def self.count
    participants.size
  end

  def self.add(user_token)
    new_participants = participants | Array.wrap(user_token)
    cache.write(:participants, new_participants)
    new_participants
  end

  def self.remove(user_token)
    new_participants = participants - Array.wrap(user_token)
    cache.write(:participants, new_participants)
    new_participants
  end

  def self.clear
    Rails.logger.info { " -> DutyRoster#clear" }
    cache.delete(:participants)
  end

  def self.cache = Rails.cache
  private_class_method :cache
end
