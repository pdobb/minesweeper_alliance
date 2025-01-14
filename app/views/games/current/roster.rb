# frozen_string_literal: true

# Games::Current::Roster represents a simple roster (list) of all
# participants--both active and passive--currently in the War Room (channel).
class Games::Current::Roster
  def self.broadcast_roster_update(current_game:)
    WarRoomChannel.broadcast_update(
      target: turbo_frame_name,
      partial: "games/current/roster",
      locals: { roster: new(current_game:) })
  end

  def self.turbo_frame_name = :fleet_roster

  def initialize(current_game:)
    @current_game = current_game
  end

  def turbo_frame_name = self.class.turbo_frame_name

  # :reek:DuplicateMethodCall
  def game_status_emojis
    if game_standing_by?
      Emoji.anchor
    else # Sweep in Progress
      "#{Emoji.ship} #{Emoji.anchor}"
    end
  end

  def fleet_size = FleetTracker.count

  def listings
    Listing.wrap(users)
  end

  private

  attr_reader :current_game

  def game_standing_by? = current_game.status_standing_by?

  def users
    User.for_token(FleetTracker.tokens)
  end

  # Games::Current::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user)
      @user = user
    end

    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user
  end
end
