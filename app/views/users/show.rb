# frozen_string_literal: true

# Users::Show is a View Model for displaying the Users Show page.
class Users::Show
  DEFAULT_PRECISION = 1

  def initialize(user:, context:)
    @user = user
    @context = context
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def display_games_count = delimit(games_count)

  def display_winning_games_count
    "#{winning_games_count} (#{winning_games_percentage})"
  end

  def display_losing_games_count
    "#{losing_games_count} (#{losing_games_percentage})"
  end

  def display_reveals_count = delimit(reveals_count)
  def display_flags_count = delimit(flags_count)
  def display_unflags_count = delimit(unflags_count)
  def display_tripped_mines_count = delimit(tripped_mines_count)

  private

  attr_reader :user,
              :context

  def games = user.games
  def cell_reveal_transactions = user.cell_reveal_transactions
  def cell_flag_transactions = user.cell_flag_transactions
  def cell_unflag_transactions = user.cell_unflag_transactions
  def revealed_cells = user.revealed_cells

  def games_count
    @games_count ||= games.size
  end

  def winning_games_percentage = percentage(winning_games_percent)
  def winning_games_percent = winning_games_ratio * 100.0
  def winning_games_ratio = winning_games_count / games_count.to_f

  def winning_games_count
    @winning_games_count ||= games.for_status_alliance_wins.size
  end

  def losing_games_percentage = percentage(losing_games_percent)
  def losing_games_percent = losing_games_ratio * 100.0
  def losing_games_ratio = losing_games_count / games_count.to_f

  def losing_games_count
    @losing_games_count ||= games.for_status_mines_win.size
  end

  def reveals_count = cell_reveal_transactions.size
  def flags_count = cell_flag_transactions.size
  def unflags_count = cell_unflag_transactions.size
  def tripped_mines_count = revealed_cells.is_mine.size

  def percentage(value, helpers: context.helpers, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value, helpers: context.helpers)
    helpers.number_with_delimiter(value)
  end
end
