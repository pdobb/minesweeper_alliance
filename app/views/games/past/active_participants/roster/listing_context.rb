# frozen_string_literal: true

# :reek:InstanceVariableAssumption

# Games::Past::ActiveParticipants::Roster::ListingContext services the needs of
# {Games::Past::ActiveParticipants::Roster::Listing}s. It represents the
# "iteration context", efficiently revealing which {User} created/started/ended
# a {Game} without requiring each iteration to query each of these.
class Games::Past::ActiveParticipants::Roster::ListingContext
  attr_reader :game

  def initialize(game:)
    @game = game
  end

  # :reek:NilCheck
  def show_game_participation_indicators?
    if @show_game_participation_indicators.nil?
      @show_game_participation_indicators = game.active_participants.many?
    else
      @show_game_participation_indicators
    end
  end

  def game_creator?(user) = user == game_creator
  def game_starter?(user) = user == game_starter
  def game_ender?(user) = user == game_ender

  private

  def game_creator = @game_creator ||= game.game_create_transaction.user
  def game_starter = @game_starter ||= game.game_start_transaction.user
  def game_ender = @game_ender ||= game.game_end_transaction.user
end
