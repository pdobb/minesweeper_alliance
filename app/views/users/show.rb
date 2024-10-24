# frozen_string_literal: true

# Users::Show is a View Model for displaying the Users Show page.
class Users::Show
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(user:)
    @user = user
  end

  def cache_name
    [user, _completed_games_count]
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def games_count = delimit(_completed_games_count)

  def winning_games_count
    return 0 if _winning_games_count.zero?

    "#{_winning_games_count} (#{winning_games_percentage})"
  end

  def losing_games_count
    return 0 if _losing_games_count.zero?

    "#{_losing_games_count} (#{losing_games_percentage})"
  end

  def reveals_count = delimit(_reveals_count)
  def chords_count = delimit(_chords_count)
  def flags_count = delimit(_flags_count)
  def unflags_count = delimit(_unflags_count)
  def tripped_mines_count = delimit(_tripped_mines_count)

  def best_score
    score = _best_score
    score ? score.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def best_bbbvps
    bbbvps = _best_bbbvps
    bbbvps ? bbbvps.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def best_efficiency
    efficiency = _best_efficiency
    efficiency ? percentage(efficiency * 100.0) : NO_VALUE_INDICATOR
  end

  private

  attr_reader :user

  def games = user.games

  def _completed_games_count
    @_completed_games_count ||= games.for_game_over_statuses.size
  end

  def winning_games_percentage = percentage(winning_games_percent)
  def winning_games_percent = winning_games_ratio * 100.0
  def winning_games_ratio = _winning_games_count / _completed_games_count.to_f

  def _winning_games_count
    @_winning_games_count ||= games.for_status_alliance_wins.size
  end

  def losing_games_percentage = percentage(losing_games_percent)
  def losing_games_percent = losing_games_ratio * 100.0
  def losing_games_ratio = _losing_games_count / _completed_games_count.to_f

  def _losing_games_count
    @_losing_games_count ||= games.for_status_mines_win.size
  end

  def _reveals_count = cell_reveal_transactions.size
  def cell_reveal_transactions = user.cell_reveal_transactions

  def _chords_count = cell_chord_transactions.size
  def cell_chord_transactions = user.cell_chord_transactions

  def _flags_count = cell_flag_transactions.size
  def cell_flag_transactions = user.cell_flag_transactions

  def _unflags_count = cell_unflag_transactions.size
  def cell_unflag_transactions = user.cell_unflag_transactions

  def _tripped_mines_count = user.revealed_cells.is_mine.size

  def _best_score = user.games.by_score_asc.pick(:score)
  def _best_bbbvps = user.games.by_bbbvps_desc.pick(:bbbvps)
  def _best_efficiency = user.games.by_efficiency_desc.pick(:efficiency)

  def percentage(value, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value)
    helpers.number_with_delimiter(value)
  end

  def helpers = ActionController::Base.helpers
end
