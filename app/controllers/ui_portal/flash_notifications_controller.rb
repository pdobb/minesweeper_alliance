# frozen_string_literal: true

class UIPortal::FlashNotificationsController < UIPortal::BaseController
  # @example /ui/flash_notifications
  # @example /ui/flash_notifications?count=3&timeout=1
  def show
    sample_messages.first(count).each do |message|
      type = Application::Flash.notification_types.sample
      notifications = (flash.now[type] ||= [])
      notifications << {
        text: message.html_safe, # rubocop:disable Rails/OutputSafety
        timeout:,
      }
    end
  end

  private

  def sample_messages
    t("flash").flat_map { |_, value|
      Array.wrap(value).map { I18n.interpolate(it, dummy_values) }
    }.shuffle!
  end

  def dummy_values
    @dummy_values ||= {
      url: "/ui/flash_notifications",
      type: "[Example Type]",
      category: "[Example Category]",
      to: "[New Value]",
      name: "[Example Name]",
    }
  end

  def count(default: 8)
    (params[:count] || default).to_i
  end

  def timeout(default: 10)
    params.key?(:timeout) ? params[:timeout].to_i : [nil, default].sample
  end
end
