# frozen_string_literal: true

# Games::Stats is a View Model for displaying end-of-{Game} stats.
#
# @see Games::Results
class Games::Stats
  def initialize(game:)
    @game = game
  end

  def cache_name = [game, :stats]

  def duration
    Duration.new(game.started_at..game.ended_at)
  end

  def players_count
    game.users.size
  end

  def reveals_count
    game.cell_reveal_transactions.size
  end

  def flags_count
    game.cell_flag_transactions.size
  end

  def unflags_count
    game.cell_unflag_transactions.size
  end

  private

  attr_reader :game
end
