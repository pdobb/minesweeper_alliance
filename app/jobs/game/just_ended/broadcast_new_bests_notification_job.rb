# frozen_string_literal: true

class Game::JustEnded::BroadcastNewBestsNotificationJob < ApplicationJob
  queue_as :default

  def perform(game)
    return if (collection = notifications_for(game)).none?

    Turbo::StreamsChannel.broadcast_prepend_to(
      Application::Layout.turbo_stream_name,
      target: Application::Flash.turbo_target,
      partial: "application/flash/notification",
      collection:,
    )
  end

  private

  def notifications_for(game)
    game.best_categories.map { |category|
      text = random_message_for(game:, category:)
      build_notification(text:)
    }
  end

  def random_message_for(game:, category:)
    url = Router.game_path(game)
    type = game.type
    I18n.t("flash.new_best_game_html", url:, type:, category:).sample.html_safe
  end

  def build_notification(text:)
    Application::Flash::Notification.new(
      type: :info,
      content: { text:, timeout: false },
    )
  end
end
