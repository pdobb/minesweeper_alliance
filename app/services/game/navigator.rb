# frozen_string_literal: true

# Game::Navigator provides chronological navigation operators. e.g. for getting
# the previous or next {Game}, relative to a given {Game}.
module Game::Navigator
  def self.previous(game:, base_arel: Game)
    base_arel
      .excluding(game)
      .for_created_at(..game.created_at)
      .by_most_recent
      .take
  end

  def self.next(game:, base_arel: Game)
    base_arel
      .excluding(game)
      .for_created_at(game.created_at..)
      .by_least_recent
      .take
  end
end
