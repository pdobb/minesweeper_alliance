# frozen_string_literal: true

# Games::Stats is a view model for displaying statistics about a {Game}.
class Games::Stats
  def initialize(game:)
    @game = game
  end

  def show_sign_link?(user:)
    user.participated_in?(game)
  end

  def duration
    Duration.new(game.started_at..game.ended_at)
  end

  def players_count
    duty_roster.size
  end

  def duty_roster
    @duty_roster ||= game.users
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
