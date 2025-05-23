# frozen_string_literal: true

# Games::Past::Status represents the status (victory vs defeat) for past
# {Game}s.
class Games::Past::Status
  def initialize(game:)
    @game = game
  end

  def css
    if ended_in_defeat?
      %w[text-red-700 dark:text-red-600]
    elsif ended_in_victory?
      %w[text-green-700 dark:text-green-600]
    end
  end

  def to_s
    game.status
  end

  def active_participants_count = game.active_participants_count
  def statusmoji = past_game_view.statusmoji

  private

  attr_reader :game

  def ended_in_defeat? = Game::Status.ended_in_defeat?(game)
  def ended_in_victory? = Game::Status.ended_in_victory?(game)

  def past_game_view = @past_game_view ||= Games::Past.new(game:)
end
