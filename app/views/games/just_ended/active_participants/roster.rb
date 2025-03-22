# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Roster represents a list of {User}s
# that actively participated in a just-ended {Game}.
#
# @see Games::Past::ActiveParticipants::Roster
class Games::JustEnded::ActiveParticipants::Roster
  def initialize(game:)
    @game = game
  end

  def listings
    Games::JustEnded::ActiveParticipants::Roster::Listing.wrap(
      sorted_users, context:)
  end

  private

  attr_reader :game

  def sorted_users
    game.active_participants.by_participated_at_asc.uniq
  end

  def context
    @context ||=
      Games::Past::ActiveParticipants::Roster::ListingContext.new(game:)
  end
end
