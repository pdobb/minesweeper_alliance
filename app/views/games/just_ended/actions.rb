# frozen_string_literal: true

# Games::JustEnded::Actions represents represents the {Game} actions area for
# {Game}s that have just ended.
class Games::JustEnded::Actions
  def initialize(game:)
    @game = game
  end

  def game_over_message
    if game_ended_in_victory?
      I18n.t("game.victory.restart_html").sample
    else # game_ended_in_defeat?
      I18n.t("game.defeat.restart_html").sample
    end.html_safe
  end

  def new_game_content
    Games::JustEnded::NewGameContent.new
  end

  private

  attr_reader :game

  def game_ended_in_victory? = game.ended_in_victory?
end
