# frozen_string_literal: true

# Application::Flash wraps Rails' flash hash (ActionDispatch::Flash::FlashHash)
# to pull together an Array of {Application::Flash::Notification} objects--for
# display in the view layout.
#
# Note: We only wrap up flash has types from {.notification_types}. This way, we
# can still use Rails' flash hash for other things as well.
class Application::Flash
  def self.notification_types
    @notification_types ||= %w[alert notice info warning].freeze
  end

  def self.turbo_target = "flash"

  def initialize(flash_hashes)
    @flash_hashes = flash_hashes
  end

  def turbo_target = self.class.turbo_target

  def notifications
    flash_hashes.flat_map { |type, hashes|
      next unless type.in?(self.class.notification_types)

      Notification.wrap(hashes, type:)
    }.tap(&:compact!)
  end

  private

  attr_reader :flash_hashes
end
