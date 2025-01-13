# frozen_string_literal: true

# Games::Show represents past {Game}s.
class Games::Show
  def initialize(game:)
    @game = game
  end

  def game_number = game.display_id

  def page_nav(context:)
    Games::Past::PageNav.new(game:, context:)
  end

  def container
    Games::Past::Container.new(game:)
  end

  private

  attr_reader :game
end
