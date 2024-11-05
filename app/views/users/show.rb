# frozen_string_literal: true

# Users::Show represents {User} Show pages, detailing {User} stats and past
# {Game}s history.
class Users::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def service_record
    Users::ServiceRecord.new(user:)
  end

  def bests
    Users::Bests.new(user:)
  end

  def games
    Users::Games.new(
      base_arel: user.games.for_game_over_statuses.by_most_recently_ended,
      user:)
  end

  private

  attr_reader :user
end
