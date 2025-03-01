# frozen_string_literal: true

# Users::Show represents {User} Show pages, detailing {User} stats and past
# {Game}s history.
class Users::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name
  def updateable_display_name = View.updateable_display_name(user:)

  def dev?
    User::Current.dev?(user)
  end

  def enlistment_date = I18n.l(user.created_at.to_date)
  def time_zone = user.time_zone || View.no_value_indicator_tag

  def service_record
    Users::ServiceRecord.new(user:)
  end

  def bests
    Users::Bests.new(user:)
  end

  def display_case
    DisplayCase.new
  end

  def games_index(context:)
    Users::Games::Index.new(
      base_arel: user.actively_participated_in_games.for_game_over_statuses,
      user:,
      context:)
  end

  private

  attr_reader :user

  # Users::Show::DisplayCase
  class DisplayCase
    include Games::Past::DisplayCaseBehaviors
  end
end
