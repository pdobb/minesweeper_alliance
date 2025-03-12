# frozen_string_literal: true

# Metrics::Engagements::Bests::Listing
class Metrics::Engagements::Bests::Listing
  include WrapMethodBehaviors
  include Games::Past::ActiveLinkBehaviors

  def initialize(game)
    @game = game
  end

  def score
    return Game::MAX_SCORE if game_score >= Game::MAX_SCORE

    View.round(game_score)
  end

  def fleet_size = game.active_participants.size
  def game_url = Router.metrics_game_path(game)

  private

  attr_reader :game

  def game_score = game.score
end
