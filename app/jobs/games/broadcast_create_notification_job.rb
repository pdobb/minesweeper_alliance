# frozen_string_literal: true

# Games::BroadcastCreateNotificationJob
class Games::BroadcastCreateNotificationJob < ApplicationJob
  queue_as :default

  def perform
    Turbo::StreamsChannel.broadcast_update_to(
      Games::JustEnded::ActiveParticipants::Footer.turbo_stream_name,
      target: :new_game_notification_container,
      partial: "layouts/flash/notifications",
      locals: { notifications: new_current_game_notification })
  end

  private

  def new_current_game_notification
    Application::Flash::Notification.new(
      type: :info,
      content: {
        text: I18n.t("flash.new_current_game_html").html_safe,
        timeout: false,
      })
  end
end
