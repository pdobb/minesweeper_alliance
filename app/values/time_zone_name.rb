# frozen_string_literal: true

# TimeZoneName rewrites legacy browser time zone identifiers to names
# ActiveSupport::TimeZone accepts.
#
# Browsers still report Asia/Calcutta. That link now lives in Debian's
# tzdata-legacy package, which the production image does not install.
# Time.find_zone! then raises ArgumentError: Invalid Timezone: Asia/Calcutta.
# https://app.honeybadger.io/projects/129535/faults/122967045
class TimeZoneName
  LEGACY_IDENTIFIERS = {
    "Asia/Calcutta" => "Kolkata",
  }.freeze
  private_constant :LEGACY_IDENTIFIERS

  def self.canonical(name)
    return name if name.blank?

    LEGACY_IDENTIFIERS.fetch(name, name)
  end
end
