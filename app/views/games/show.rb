# frozen_string_literal: true

# Games::Show represents past {Game}s.
class Games::Show
  def initialize(game:)
    @game = game
  end

  def game_number = game.display_id

  def nav
    Games::Past::Nav.new(game:)
  end

  def show
    Games::Past::Show.new(game:)
  end

  private

  attr_reader :game
end
