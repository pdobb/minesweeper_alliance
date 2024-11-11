# frozen_string_literal: true

# Metrics::Games::Show represents past {Game}s in the context of the Metrics
# Show page.
class Metrics::Games::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def game_number = game.display_id

  def container
    Metrics::Games::Container.new(game:)
  end

  private

  attr_reader :game,
              :user
end
