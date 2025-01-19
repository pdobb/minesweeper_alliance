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
# fleet. See: {Games::Current::BroadcastRosterUpdateJob}.
#
# Similarly, use {.activate!} to activate and then broadcast the current
# {User}'s participation status to the fleet--but only if this was the first
# activation. Activated entries cannot (should not) be deactivated.
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
module FleetTracker
  DEFAULT_ATTRIBUTES = { active: false, expires_at: nil }.freeze

  ADDITION_BROADCAST_DELAY_SECONDS = 0.seconds

  REMOVAL_DELAY_SECONDS = 2.seconds
  REMOVAL_BROADCAST_DELAY_SECONDS = REMOVAL_DELAY_SECONDS + 1

  def self.registry
    Registry.new(cache.fetch(:registry) { [] })
  end

  def self.tokens = registry.tokens

  def self.count = registry.count

  def self.add(token)
    hash = { token: }.with_defaults(DEFAULT_ATTRIBUTES)
    updated_registry = registry.add(hash)
    cache.write(:registry, updated_registry.to_a)

    registry
  end

  def self.add!(token:)
    add(token)
    broadcast_roster_update(wait: ADDITION_BROADCAST_DELAY_SECONDS)
  end

  def self.activate(token)
    updated_registry = registry.activate(token)
    cache.write(:registry, updated_registry.to_a)

    registry
  end

  def self.activate!(token:)
    return if registry.active?(token)

    activate(token)
    broadcast_participation_status_update(token:)
  end

  def self.remove(token)
    return registry if registry.exclude?(token)

    updated_registry =
      registry.update(token:, expires_at: REMOVAL_DELAY_SECONDS.from_now)
    cache.write(:registry, updated_registry.to_a)

    registry
  end

  def self.remove!(token:)
    remove(token)
    broadcast_roster_update(wait: REMOVAL_BROADCAST_DELAY_SECONDS)
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

  def self.broadcast_roster_update(wait:)
    Games::Current::BroadcastRosterUpdateJob.set(wait:).perform_later
  end
  private_class_method :broadcast_roster_update

  def self.broadcast_participation_status_update(token:)
    user = User.for_token(token).take!
    Home::Roster.broadcast_participation_status_update(user:)
  end
  private_class_method :broadcast_participation_status_update

  def self.cache = Rails.cache
  private_class_method :cache

  # FleetTracker::Registry is an Array of Hashes indexed by a `token`. Each hash
  # has, by default, the following keys:
  # - `active` (Boolean)
  # - `expires_at` (DateTime, NilClass) if `nil`, the entry won't expire on its
  #   own.
  class Registry
    def initialize(array = [])
      @array = Array.wrap(array)
    end

    def count = array.size
    def to_a = array.dup

    def find(token)
      array.detect { |hash| hash.fetch(:token) == token }
    end

    def add(entry)
      array << entry if exclude?(entry.fetch(:token))

      self
    end

    def update(entry)
      return self unless (hash = find(entry.fetch(:token)))

      hash.update(entry)

      self
    end

    def activate(token)
      find(token)&.update(active: true)

      self
    end

    def active?(token)
      find(token)&.fetch(:active)
    end

    def excluding_expired
      array.reject! { |hash| hash.fetch(:expires_at)&.past? }

      self
    end

    def tokens = array.pluck(:token)

    def include?(token) = !!find(token)
    def exclude?(token) = !include?(token)

    private

    attr_reader :array
  end
end
