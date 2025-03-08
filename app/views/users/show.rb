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

  # :reek:DuplicateMethodCall

  def time_zone
    return View.no_value_indicator_tag unless user_time_zone?

    ActiveSupport::TimeZone.new(user_time_zone).to_s
  rescue TZInfo::InvalidTimezoneIdentifier
    View.no_value_indicator_tag
  end

  def local_time
    return unless user_time_zone?

    I18n.l(
      Time.current.in_time_zone(user_time_zone),
      format: :weekday_hours_minutes)
  rescue TZInfo::InvalidTimezoneIdentifier
    nil
  end

  def display_local_time
    local_time || View.no_value_indicator_tag
  end

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

  def user_time_zone? = user.time_zone?
  def user_time_zone = user.time_zone

  # Users::Show::DisplayCase
  class DisplayCase
    include Games::Past::DisplayCaseBehaviors
  end
end
