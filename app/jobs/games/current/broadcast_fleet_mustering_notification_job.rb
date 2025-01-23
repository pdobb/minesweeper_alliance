# frozen_string_literal: true

# Games::Current::BroadcastFleetMusteringNotificationJob
class Games::Current::BroadcastFleetMusteringNotificationJob < ApplicationJob
  queue_as :default

  def perform
    Turbo::StreamsChannel.broadcast_update_to(
      Games::JustEnded::ActiveParticipants::Footer.turbo_stream_name,
      target: "fleetMusteringNotificationContainer",
      partial: "layouts/flash/notifications",
      locals: { notifications: notification })
  end

  private

  def notification
    Application::Flash::Notification.new(
      type: :info,
      content: {
        text: I18n.t("flash.fleet_mustering_notification_html").html_safe,
        timeout: false,
      })
  end
end
