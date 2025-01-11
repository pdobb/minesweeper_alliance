# frozen_string_literal: true

# Games::JustEnded::Participants::Form represents the {User} "signature" form
# that shows at {Game} end for participating {User}s.
class Games::JustEnded::Participants::Form
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def to_model = user

  def post_url = Router.just_ended_game_participants_path(game)
  def cancel_url = Router.just_ended_game_participants_path(game)

  private

  attr_reader :game,
              :user
end
