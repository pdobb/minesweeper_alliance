# frozen_string_literal: true

# FleetTracker keeps track of all {User}s--both active ("Active Participants")
# and passive ("Observers")--currently in the War Room channel. This accounting
# is {.reset} at the start of each new {Game}.
#
# FleetTracker makes up for jitter, or "shakiness" of add/remove calls in close
# time proximity in that:
# - {.add} simply unions in new entries into {.registry} (by the given `token`
#   value), so that repeat adds aren't double counted.
# - {.remove} marks an item as expired, but doesn't actually remove it from the
#   internal registry. Expiration is also future-dated by
#   {REMOVAL_DELAY_SECONDS} seconds, so that e.g. page reloads don't show a
#   {User} quickly jumping out of and back into the Fleet Roster.
#   - By not actually removing entries, we assure that a follow-up re-{.add}
#     will simply un-expire the item, restoring its original state.
#
# Use {.add!}/{.remove!} to:
# 1. add/remove a {User} entry
# 2. broadcast the appropriate UI updates to the fleet.
#
# Similarly, use {.activate!} to:
# 1. activate a {User} entry
# 2. broadcast the appropriate participation status update to the fleet--but
#    only if this was the first activation for the entry.
#
# Activated entries cannot (and should not) be deactivated. Again, the
# FleetTracker is {.reset} at the start of each new {Game}.
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
module FleetTracker
  CACHE_KEY = :fleet_tracker

  REMOVAL_DELAY_SECONDS = 2.seconds
  REMOVAL_BROADCAST_DELAY_SECONDS = REMOVAL_DELAY_SECONDS + 1

  def self.registry
    Registry.new(cache.fetch(CACHE_KEY) { [] })
  end

  def self.count = registry.size

  def self.tokens = registry.tokens

  def self.add(token)
    write { registry.add(token) }
  end

  def self.add!(token)
    do_broadcast = registry.new_or_expired_entry?(token)
    add(token)
    broadcast_fleet_addition(token:) if do_broadcast
  end

  def self.activate(token)
    write { registry.activate(token) }
  end

  def self.activate!(token)
    return if registry.active?(token)

    activate(token)
    broadcast_fleet_participation_status_update(token:)
  end

  def self.remove(token)
    write { registry.set_expiration(token) }
  end

  def self.remove!(token)
    remove(token).tap {
      broadcast_fleet_removal(token:, wait: REMOVAL_BROADCAST_DELAY_SECONDS)
    }
  end

  def self.expired?(token)
    registry.expired?(token)
  end

  def self.reset
    cache.delete(CACHE_KEY)
  end

  def self.broadcast_fleet_size_update
    WarRoomChannel.broadcast_update(
      target: Games::Current::Status.fleet_size_turbo_update_target,
      html: FleetTracker.count)
  end

  def self.broadcast_fleet_addition(token:)
    broadcast_fleet_size_update

    user = find_user(token)
    active = registry.active?(token)
    WarRoomChannel.broadcast_append(
      target: Home::Roster.turbo_target,
      partial: "home/roster/listing",
      locals: { listing: Home::Roster::Listing.new(user:, active:) })
  end
  private_class_method :broadcast_fleet_addition

  def self.broadcast_fleet_removal(token:, wait:)
    Games::Current::BroadcastFleetRemovalJob.set(wait:).perform_later(token)
  end
  private_class_method :broadcast_fleet_removal

  # If a {User}'s participation status is being updated, it means they've just
  # become active.
  def self.broadcast_fleet_participation_status_update(token:)
    user = find_user(token)
    WarRoomChannel.broadcast_update(
      target: Home::Roster::Listing.participation_status_turbo_target(user:),
      html: Emoji.ship)
  end
  private_class_method :broadcast_fleet_participation_status_update

  def self.find_user(token) = User.for_token(token).take!
  private_class_method :find_user

  def self.write
    yield.tap { |updated_registry|
      cache.write(CACHE_KEY, updated_registry.to_a)
    }
  end
  private_class_method :write

  def self.cache = Rails.cache
  private_class_method :cache

  # FleetTracker::Registry is collection of {FleetTracker::Registry::Entry}s.
  class Registry
    attr_reader :entries

    def initialize(array = [])
      @entries = Entry.wrap(array)
    end

    def to_a = entries.map(&:to_h)
    def size = entries.count(&:not_expired?)
    def tokens = unexpired_sorted_entries.pluck(:token)

    def new_or_expired_entry?(token)
      return true unless (entry = find(token))

      entry.expired?
    end

    def add(token)
      if (entry = find(token))
        entry.clear_expiration
      else
        entries << Entry.new(token:)
      end

      self
    end

    def active?(token) = find(token)&.active?

    def activate(token)
      find_or_add(token).set_active
      self
    end

    def set_expiration(token) # rubocop:disable Naming/AccessorMethodName
      find(token)&.set_expiration
      self
    end

    def expired?(token) = find(token).expired?

    private

    def unexpired_sorted_entries = unexpired_entries.sort_by(&:created_at)
    def unexpired_entries = entries.reject(&:expired?)

    def find(token)
      entries.detect { |entry| entry.token?(token) }
    end

    def find_or_add(token)
      add(token)
      find(token)
    end

    # FleetTracker::Registry::Entry represents a {User}'s current state in the
    # Fleet Roster.
    #
    # @attr token [String] The {User#token} that this Entry represents.
    # @attr active [Boolean] (false) Whether or not the {User} is actively
    #   participating in the {Game}.
    # @attr expires_at [DateTime, NilClass] (nil) The DateTime after which the
    #   {User} associated an {Entry#token} is considered to have "gone away".
    # @attr created_at [DateTime] (Time.current) Used for sorting Entries by
    #   join order.
    class Entry
      attr_reader :token,
                  :active,
                  :expires_at,
                  :created_at

      def self.wrap(hashes)
        Array.wrap(hashes).map { |hash| new(**hash) }
      end

      # :reek:BooleanParameter
      def initialize(
            token:,
            active: false,
            expires_at: nil,
            created_at: Time.current)
        @token = token
        @active = active
        @expires_at = expires_at
        @created_at = created_at
      end

      def [](key) = to_h[key]
      def to_h = { token:, active:, expires_at:, created_at: }

      def token?(other) = token == other

      def set_active = self.active = true
      def active? = !!active

      def set_expiration = self.expires_at = REMOVAL_DELAY_SECONDS.from_now
      def clear_expiration = self.expires_at = nil

      def not_expired? = !expired?

      def expired?
        return false unless expires_at

        expires_at <= Time.current
      end

      private

      attr_writer :active,
                  :expires_at

      concerning :ObjectInspection do
        include ObjectInspectionBehaviors

        private

        def inspect_identification = identify(:token)

        def inspect_flags(scope:)
          scope.join_flags([
            active? ? Emoji.ship : Emoji.anchor,
            expired? ? Emoji.hide : Emoji.eyes,
          ])
        end
      end
    end
  end
end
