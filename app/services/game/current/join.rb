# frozen_string_literal: true

# Game::Current::Join manages what happens when a {User} (or {Guest}) joins (as
# in visits, views, or otherwise witnesses) a {Game}.
#
# This service is meant to be idempotent. So, while it makes sense to only call
# this service once--the first time a {Game} is joined--it can be called
# multiple times without negative consequences. This relies heavily on the fact
# that {ParticipantTransaction.create_between} will fail to validate (without
# raising an exception) if the given {User} has already joined the given {Game}
# before.
#
# Simply joining a {Game} is not considered to be active participation in that
# {Game}. Therefore, if the given user is actually a {Guest}, we just abort
# early-- before creating a {ParticipantTransaction} record.
class Game::Current::Join
  def self.call(...) = new(...).call

  def initialize(user:, game:)
    @user = user
    @game = game
  end

  def call
    return unless game
    return if user_is_actually_a_guest?

    ParticipantTransaction.create_between(user:, game:)
    FleetTracker.add!(user.token)
  end

  private

  attr_reader :user,
              :game

  def user_is_actually_a_guest? = !user.participant?
end
