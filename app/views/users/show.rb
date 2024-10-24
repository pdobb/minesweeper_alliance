# frozen_string_literal: true

# Users::Show is a View Model for displaying the Users Show page.
class Users::Show
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(user:)
    @user = user
  end

  def cache_name
    [user, completed_games_count]
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def display_games_count = delimit(completed_games_count)

  def display_winning_games_count
    return 0 if winning_games_count.zero?

    "#{winning_games_count} (#{winning_games_percentage})"
  end

  def display_losing_games_count
    return 0 if losing_games_count.zero?

    "#{losing_games_count} (#{losing_games_percentage})"
  end

  def display_reveals_count = delimit(reveals_count)
  def display_chords_count = delimit(chords_count)
  def display_flags_count = delimit(flags_count)
  def display_unflags_count = delimit(unflags_count)
  def display_tripped_mines_count = delimit(tripped_mines_count)

  def display_best_score
    score = best_score
    score ? score.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def display_best_bbbvps
    bbbvps = best_bbbvps
    bbbvps ? bbbvps.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def display_best_efficiency
    efficiency = best_efficiency
    efficiency ? percentage(efficiency * 100.0) : NO_VALUE_INDICATOR
  end

  private

  attr_reader :user

  def games = user.games
  def cell_reveal_transactions = user.cell_reveal_transactions
  def cell_chord_transactions = user.cell_chord_transactions
  def cell_flag_transactions = user.cell_flag_transactions
  def cell_unflag_transactions = user.cell_unflag_transactions
  def revealed_cells = user.revealed_cells

  def completed_games_count
    @completed_games_count ||= games.for_game_over_statuses.size
  end

  def winning_games_percentage = percentage(winning_games_percent)
  def winning_games_percent = winning_games_ratio * 100.0
  def winning_games_ratio = winning_games_count / completed_games_count.to_f

  def winning_games_count
    @winning_games_count ||= games.for_status_alliance_wins.size
  end

  def losing_games_percentage = percentage(losing_games_percent)
  def losing_games_percent = losing_games_ratio * 100.0
  def losing_games_ratio = losing_games_count / completed_games_count.to_f

  def losing_games_count
    @losing_games_count ||= games.for_status_mines_win.size
  end

  def reveals_count = cell_reveal_transactions.size
  def chords_count = cell_chord_transactions.size
  def flags_count = cell_flag_transactions.size
  def unflags_count = cell_unflag_transactions.size
  def tripped_mines_count = revealed_cells.is_mine.size
  def best_score = user.games.by_score_asc.pick(:score)
  def best_bbbvps = user.games.by_bbbvps_desc.pick(:bbbvps)
  def best_efficiency = user.games.by_efficiency_desc.pick(:efficiency)

  def percentage(value, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value)
    helpers.number_with_delimiter(value)
  end

  def helpers = ActionController::Base.helpers
end
