# frozen_string_literal: true

# Users::ServiceRecord represents the "Service Record" (counts on total
# engagements, {Cell}s revealed, flags placed, etc.) section on {User} Show
# pages.
class Users::ServiceRecord
  def initialize(user:)
    @user = user
  end

  def cache_key
    [
      user,
      :service_record,
      completed_games_count,
    ]
  end

  def games_count = View.delimit(completed_games_count)

  def winning_games_count
    return 0 if _winning_games_count.zero?

    "#{_winning_games_count} (#{winning_games_percentage})"
  end

  def losing_games_count
    return 0 if _losing_games_count.zero?

    "#{_losing_games_count} (#{losing_games_percentage})"
  end

  def reveals_count = View.delimit(_reveals_count)
  def chords_count = View.delimit(_chords_count)
  def flags_count = View.delimit(_flags_count)
  def unflags_count = View.delimit(_unflags_count)
  def tripped_mines_count = View.delimit(_tripped_mines_count)

  private

  attr_reader :user

  def completed_games_count
    @completed_games_count ||= user.completed_games_count
  end

  def _winning_games_count
    @_winning_games_count ||= games_arel.for_status_alliance_wins.size
  end

  def winning_games_percentage = View.percentage(winning_games_percent)
  def winning_games_percent = winning_games_ratio * 100.0
  def winning_games_ratio = _winning_games_count / completed_games_count.to_f

  def _losing_games_count
    @_losing_games_count ||= games_arel.for_status_mines_win.size
  end

  def losing_games_percentage = View.percentage(losing_games_percent)
  def losing_games_percent = losing_games_ratio * 100.0
  def losing_games_ratio = _losing_games_count / completed_games_count.to_f

  def _reveals_count = user.cell_reveal_transactions.size
  def _chords_count = user.cell_chord_transactions.size
  def _flags_count = user.cell_flag_transactions.size
  def _unflags_count = user.cell_unflag_transactions.size
  def _tripped_mines_count = user.revealed_cells.is_mine.size

  def games_arel = user.games
end
