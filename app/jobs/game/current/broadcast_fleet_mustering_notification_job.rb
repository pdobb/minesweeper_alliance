# frozen_string_literal: true

class Game::Current::BroadcastFleetMusteringNotificationJob < ApplicationJob
  queue_as :default

  def perform
    Turbo::StreamsChannel.broadcast_prepend_to(
      Games::JustEnded::ActiveParticipants::Footer.turbo_stream_name,
      target: Application::Flash.turbo_target,
      partial: "application/flash/notification",
      locals: { notification: })
  end

  private

  def notification
    text = I18n.t("flash.fleet_mustering_notification_html").html_safe

    Application::Flash::Notification.new(
      type: :info,
      content: {
        id: "fleetMusteringNotification",
        text:,
        timeout: false,
      })
  end
end
