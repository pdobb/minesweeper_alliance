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

  def self.turbo_target(entry:) = "home_roster_listing-#{entry.token}"

  # @attr entry [FleetTracker::Registry::Entry]
  def initialize(entry)
    @entry = entry
  end

  def turbo_target = self.class.turbo_target(entry:)

  def expired? = entry.expired?
  def updateable_display_name = View.updateable_display_name(user:)

  def show_user_url
    Router.user_path(user)
  end

  def username_turbo_target = View.dom_id(user)

  def participation_status_title
    active? ? "Active Participant" : "Observer"
  end

  def participation_statusmoji
    active? ? Emoji.ship : Emoji.anchor
  end

  private

  attr_reader :entry

  def user = @user ||= User.find(token)
  def token = entry.token
  def active? = entry.active?
end
