# frozen_string_literal: true

# FleetTracker accounts for all {User}s--both active ("Active Participants")
# and passive ("Observers")--currently in the War Room channel. This accounting
# is {.reset} at the start of each new {Game}. Internally, data for the
# {FleetTracker::Registry} is stored in the Rails cache.
#
# FleetTracker makes up for jitter, or "shakiness" of add/expire calls in close
# time proximity in that:
# - {.add} simply unions in new entries into the registry (by the given `token`
#   value), so that repeated {.add}s aren't double-counted.
# - {.expire} marks an entry as expired, future-dated by {EXPIRATION_SECONDS}
#   seconds, so that e.g. page reloads don't show a {User} quickly jumping out
#   of and then immediately back into the Fleet Roster.
#   - By just expiring and not actually removing entries, we also allow for:
#     1. Follow-up re-{.add}s to simply unexpire the entry, restoring its
#        original state. This includes their "Active Participant" vs
#        "Observer"-only status as well as just the overall, original sort order
#        of the registry.
#     2. Displaying a {User} as away (after expiration) by dimming their name
#        in the Fleet Roster.
#
# Use {.add!}/{.expire!} to:
# 1. Add/expire a {User} entry, and then:
# 2. Broadcast the appropriate UI updates to the fleet.
#
# Similarly, use {.activate!} to:
# 1. Activate a {User} entry, and then:
# 2. Broadcast the appropriate participation status update to the fleet--but
#    only if this was the first activation for the entry.
#
# Activated entries cannot (and should not) be deactivated. Again, the
# FleetTracker is {.reset} at the start of each new {Game}.
#
# FleetTracker only tracks {User}s, not {Guest}s. Guests are "transparent" right
# up until they actively participate in a {Game}, at which time they're
# converted in to {User}s.
#
# @see ApplicationCable::Connection
# @see WarRoomChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
module FleetTracker
  EXPIRATION_SECONDS = 2.seconds
  DEEP_EXPIRATION_MINUTES = 3.minutes

  def self.to_a = registry.to_a
  def self.entries = registry.entries
  def self.find(token) = registry.find(token)
  def self.size = registry.size

  def self.add!(token)
    is_new = registry.missing?(token)
    is_expired = registry.expired?(token) unless is_new

    entry = add(token)

    broadcast_fleet_addition(entry:) if is_new
    broadcast_fleet_entry_update(entry:) if is_expired
  end

  def self.add(token) = registry.add(token)

  def self.activate!(token)
    return if registry.active?(token)

    entry = activate(token)
    broadcast_fleet_entry_update(entry:)
  end

  def self.activate(token) = registry.activate(token)

  def self.expire!(token)
    if (entry = expire(token))
      enqueue_fleet_entry_expiration_job(entry:, wait: EXPIRATION_SECONDS)
    end
  end

  def self.expire(token)
    return if registry.missing_or_expired?(token)

    registry.expire(token)
  end

  def self.purge_deeply_expired_entries = registry.purge_deeply_expired_entries

  def self.purge_deeply_expired_entries!
    purge_deeply_expired_entries.each do |entry|
      broadcast_fleet_entry_removal(entry:)
    end
  end

  def self.reset = registry.reset

  def self.registry = Registry.new
  private_class_method :registry

  def self.broadcast_fleet_size_update
    WarRoomChannel.broadcast_update(
      target: Games::Current::Status.fleet_size_turbo_update_target,
      html: FleetTracker.size)
  end
  private_class_method :broadcast_fleet_size_update

  def self.broadcast_fleet_addition(entry:)
    broadcast_fleet_size_update

    WarRoomChannel.broadcast_append(
      target: Home::Roster.turbo_target,
      partial: "home/roster/listing",
      locals: { listing: Home::Roster::Listing.new(entry) })
  end
  private_class_method :broadcast_fleet_addition

  def self.broadcast_fleet_entry_update(entry:)
    broadcast_fleet_size_update

    WarRoomChannel.broadcast_replace(
      target: Home::Roster::Listing.turbo_target(entry:),
      attributes: { method: :morph },
      partial: "home/roster/listing",
      locals: { listing: Home::Roster::Listing.new(entry) })
  end

  def self.enqueue_fleet_entry_expiration_job(entry:, wait:)
    Home::Roster::Listing::BroadcastEntryExpirationJob.set(wait:).perform_later(
      entry.token)
  end
  private_class_method :enqueue_fleet_entry_expiration_job

  def self.broadcast_fleet_entry_removal(entry:)
    WarRoomChannel.broadcast_remove(
      target: Home::Roster::Listing.turbo_target(entry:))
  end
  private_class_method :broadcast_fleet_entry_removal

  # :reek:TooManyMethods

  # FleetTracker::Registry is a collection of {FleetTracker::Registry::Entry}s.
  class Registry
    CACHE_KEY = :fleet_tracker

    attr_reader :entries

    def initialize(array = [])
      array = cache.fetch(CACHE_KEY) { array }
      @entries = Entry.wrap(array)
    end

    def to_a = entries.map(&:to_h)
    def size = entries.count(&:unexpired?)
    def find(token) = entries.detect { |entry| entry.token?(token) }
    def active?(token) = !!find(token)&.active?
    def missing?(token) = !find(token)
    def expired?(token) = find(token).expired?
    def missing_or_expired?(token) = missing?(token) || expired?(token)

    def add(token)
      if (entry = find(token))
        entry.unexpire
      else
        entry = Entry.new(token:)
        entries << entry
      end

      save
      entry
    end

    def activate(token)
      find_or_add(token).tap { |entry|
        entry.activate
        save
      }
    end

    def expire(token)
      find(token).tap { |entry|
        entry&.expire
        save
      }
    end

    def purge_deeply_expired_entries
      deeply_expired_entries = entries.select(&:deeply_expired?)
      return [] if deeply_expired_entries.none?

      entries.reject!(&:expired?)
      save

      deeply_expired_entries
    end

    def reset = cache.delete(CACHE_KEY)

    private

    def find_or_add(token)
      add(token)
      find(token)
    end

    def save = cache.write(CACHE_KEY, to_a)
    def cache = Rails.cache

    # FleetTracker::Registry::Entry represents a {User}'s presence and status in
    # the Fleet Roster--represented in the UI by {Home::Roster::Listing}s.
    #
    # @attr token [String] The {User#token} that this Entry represents.
    # @attr active [Boolean] (false) Whether or not the {User} is actively
    #   participating in the {Game}.
    # @attr expires_at [DateTime, NilClass] (nil) The DateTime after which the
    #   {User} associated an {Entry#token} is considered to have "gone away".
    class Entry
      attr_reader :token,
                  :active,
                  :expires_at

      def self.wrap(hashes)
        Array.wrap(hashes).map { |hash| new(**hash) }
      end

      # :reek:BooleanParameter
      def initialize(token:, active: false, expires_at: nil)
        @token = token
        @active = active
        @expires_at = expires_at
      end

      def [](key) = to_h[key]
      def to_h = { token:, active:, expires_at: }
      def ==(other) = to_h == other.to_h

      def token?(other) = token == other

      def activate = self.active = true
      def active? = !!active

      def expire = self.expires_at = EXPIRATION_SECONDS.from_now
      def unexpire = self.expires_at = nil
      def unexpired? = !expired?

      def expired?
        return false unless expires_at

        expires_at <= Time.current
      end

      def deeply_expired?(minutes: DEEP_EXPIRATION_MINUTES)
        return false unless expires_at

        expires_at + minutes <= Time.current
      end

      private

      attr_writer :active,
                  :expires_at

      concerning :ObjectInspection do
        include ObjectInspectionBehaviors

        private

        def inspect_identification = identify(:token, :expires_at)

        def inspect_flags(scope:)
          scope.join_flags([
            active? ? Emoji.ship : Emoji.anchor,
            ("EXPIRED" if expired?),
          ])
        end
      end
    end
  end
end
