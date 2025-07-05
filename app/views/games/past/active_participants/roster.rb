# frozen_string_literal: true

# Games::Past::ActiveParticipants::Roster represents a list of {User}s that
# participated in a past {Game}.
#
# @see Games::JustEnded::ActiveParticipants::Roster
class Games::Past::ActiveParticipants::Roster
  def initialize(game:)
    @game = game
  end

  def listings
    Games::Past::ActiveParticipants::Roster::Listing.wrap(
      sorted_users, context:
    )
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
