# frozen_string_literal: true

# DevPortal::RailsCache::Show represents ...
class DevPortal::RailsCache::Show
  def initialize
    @cache = Rails.cache.instance_variable_get(:@data)
  end

  def entries
    Entry.wrap_hash(cache)
  end

  private

  attr_reader :cache

  # DevPortal::RailsCache::Show::Entry
  class Entry
    include WrapMethodBehaviors

    def initialize(key, entry)
      @key = key
      @entry = entry
    end

    def display_key = key

    def display_value
      if binary_value?
        decode_binary_data
      else
        value || value.inspect
      end
    end

    def display_expires_at
      return "Never" unless expires?

      if not_expired?
        "#{to_duration(expires_at)} from now"
      else
        "#{to_duration(expired_at)} ago"
      end
    end

    def expiry = entry.expires_at.to_f

    private

    attr_reader :key,
                :entry

    def value = @value ||= entry.value

    def binary_value?
      value.is_a?(String) && value.encoding == Encoding::BINARY
    end

    def decode_binary_data
      Marshal.load(value).inspect # rubocop:disable Security/MarshalLoad
    rescue
      "[Binary Data: #{value.unpack1("H*")[0..50]}...]"
    end

    def now = @now ||= Time.current
    def expires? = !!entry.expires_at
    def not_expired? = seconds_to_expiry.positive?
    def expires_at = now - seconds_to_expiry
    def expired_at = now + seconds_to_expiry

    def seconds_to_expiry
      @seconds_to_expiry ||= (expiry - now.to_f).to_i
    end

    def to_duration(expires_at)
      Duration.new(expires_at..)
    end
  end
end
