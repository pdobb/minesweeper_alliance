# frozen_string_literal: true

# Home::Roster::Listing represents a {User} currently in the War Room (channel).
#
# As {Users} subscribe/unsubscribe from the WarRoom channel, they are
# automatically added/removed from the Roster via Turbo Stream
# updates--initiated by the {FleetTracker}.
#
# @see Home::Roster::PageLoadListing
class Home::Roster::Listing
  include WrapMethodBehaviors

  def self.turbo_target(user:) = View.dom_id(user, :home_roster_listing)

  def self.participation_status_turbo_target(user:)
    View.dom_id(user, :participation_status)
  end

  # :reek:BooleanParameter
  def initialize(user:, active:)
    @user = user
    @active = active
  end

  def turbo_target = self.class.turbo_target(user:)
  def username_turbo_target = View.dom_id(user)
  def name = user.display_name

  def show_user_url
    Router.user_path(user)
  end

  def participation_status_turbo_target
    self.class.participation_status_turbo_target(user:)
  end

  def participation_status_emoji
    active? ? Emoji.ship : Emoji.anchor
  end

  private

  attr_reader :user

  def active? = !!@active
end
