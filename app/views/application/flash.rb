# frozen_string_literal: true

# Application::Flash represents the Rails `flash` hash (collection)
# (ActionDispatch::Flash::FlashHash). It exists mainly just to pull together an
# Array of {Application::Flash::Notification} objects for display.
#
# Note: We only pay attention to {.notification_types} types. This way, the
# ActionDispatch::Flash::FlashHash can still be used for other things as well,
# as it is designed.
class Application::Flash
  def self.notification_types
    @notification_types ||= %w[alert notice info warning].freeze
  end

  def self.turbo_target = "flash"

  def initialize(collection)
    @collection = collection
  end

  def turbo_target = self.class.turbo_target

  def notifications
    collection.flat_map { |type, content|
      next unless type.in?(self.class.notification_types)

      notifications_for(type:, content:)
    }.tap(&:compact!)
  end

  private

  attr_reader :collection

  def notifications_for(type:, content:)
    Array.wrap(content).map { Notification.new(type:, content: it) }
  end
end
