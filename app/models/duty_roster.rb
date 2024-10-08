# frozen_string_literal: true

# DutyRoster represents the number of Minesweepers (players / allies) currently
# reporting for duty--or at least *viewing* the Game Board.
#
# DutyRoster allows for "shakiness" of calls to {.add}/{.remove}:
# - {.add} unions a new/updated item into {.participants} (by the given
#   `user_token` value)
# - {.remove} marks an item for removal (by {.cleanup}) after at least
#   {REMOVAL_DELAY_SECONDS}-second delay
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
module DutyRoster
  REMOVAL_DELAY_SECONDS = 2.seconds

  def self.participants
    Participants.new(cache.fetch(:participants) { [] })
  end

  def self.count = participants.count

  def self.add(user_token)
    new_participants = participants.update(user_token:, expires_at: nil)

    cache.write(:participants, new_participants.to_a)

    cleanup
  end

  def self.remove(user_token)
    return participants unless participants.includes_user_token?(user_token)

    new_participants =
      participants.update(
        user_token:,
        expires_at: REMOVAL_DELAY_SECONDS.from_now)

    cache.write(:participants, new_participants.to_a)

    cleanup
  end

  def self.cleanup
    fresh_participants = participants.excluding_expired
    cache.write(:participants, fresh_participants.to_a)

    fresh_participants
  end

  def self.clear
    Rails.logger.info { " -> DutyRoster#clear" } if App.debug?

    cache.delete(:participants)

    participants
  end

  def self.cache = Rails.cache
  private_class_method :cache

  # DutyRoster::Participants is an Array of Hashes that contain info about a
  # `user_token` and `expires_at` time. If `expires_at` is `nil` then it won't
  # expire naturally.
  class Participants
    def initialize(array = [])
      @array = Array.wrap(array)
    end

    def to_a = array.dup
    def count = array.size

    def update(other)
      existing_index = index(user_token: other.fetch(:user_token))

      if existing_index
        array[existing_index] = other
      else
        array << other
      end

      self
    end

    def excluding_expired
      array.reject! { |hash| hash.fetch(:expires_at)&.past? }

      self
    end

    def includes_user_token?(user_token)
      array.any? { |hash| hash.fetch(:user_token) == user_token }
    end

    private

    attr_reader :array

    def index(user_token:)
      array.index { |hash| hash.fetch(:user_token) == user_token }
    end
  end
end
