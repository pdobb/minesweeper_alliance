# frozen_string_literal: true

# FleetTracker represents the number of participants ({User}s)--both active
# ("Active Participants") and passive ("Observers")--currently in the War Room.
# This count is {#reset} at the start of each new {Game}.
#
# FleetTracker makes up for jitter, or "shakiness" of calls in close time
# proximity, to {.add}/{.remove} in that:
# - {.add} unions new entries into {.registry} (by the given `token` value), so
#   that repeats aren't double counted.
# - {.remove} marks an item for removal (carried out by {.prune}) after a
#   {REMOVAL_DELAY_SECONDS}-second delay.
#
# Use {.add!} and {.remove!} to also broadcast the current {.count} to the
# fleet. See: {BroadcastCurrentFleetSizeJob}.
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
module FleetTracker
  ADDITION_BROADCAST_DELAY_SECONDS = 0.seconds

  REMOVAL_DELAY_SECONDS = 2.seconds
  REMOVAL_BROADCAST_DELAY_SECONDS = REMOVAL_DELAY_SECONDS + 1

  def self.registry
    Registry.new(cache.fetch(:registry) { [] })
  end

  def self.count = registry.count

  def self.add(token)
    new_registry = registry.update(token:, expires_at: nil)
    cache.write(:registry, new_registry.to_a)

    registry
  end

  def self.add!(token:, stream:)
    add(token)
    broadcast(wait: ADDITION_BROADCAST_DELAY_SECONDS, stream:)
  end

  def self.remove(token)
    return registry unless registry.includes_token?(token)

    new_registry =
      registry.update(token:, expires_at: REMOVAL_DELAY_SECONDS.from_now)
    cache.write(:registry, new_registry.to_a)

    registry
  end

  def self.remove!(token:, stream:)
    remove(token)
    broadcast(wait: REMOVAL_BROADCAST_DELAY_SECONDS, stream:)
  end

  def self.prune
    registry.excluding_expired.tap { |pruned_registry|
      cache.write(:registry, pruned_registry.to_a)
    }
  end

  def self.reset
    Rails.logger.info { " -> FleetTracker#reset" } if App.debug?

    cache.delete(:registry)

    registry
  end

  def self.broadcast(wait:, stream:)
    BroadcastCurrentFleetSizeJob.set(wait:).perform_later(stream)
  end
  private_class_method :broadcast

  def self.cache = Rails.cache
  private_class_method :cache

  # FleetTracker::Registry is an Array of Hashes that contain info about a
  # `token` and its associated `expires_at` time. If `expires_at` is `nil` then
  # it won't expire on its own.
  class Registry
    def initialize(array = [])
      @array = Array.wrap(array)
    end

    def to_a = array.dup
    def count = array.size

    def update(entry)
      existing_index = index(token: entry.fetch(:token))

      if existing_index
        array[existing_index] = entry
      else
        array << entry
      end

      self
    end

    def excluding_expired
      array.reject! { |hash| hash.fetch(:expires_at)&.past? }

      self
    end

    def includes_token?(token)
      array.any? { |hash| hash.fetch(:token) == token }
    end

    private

    attr_reader :array

    def index(token:)
      array.index { |hash| hash.fetch(:token) == token }
    end
  end
end
