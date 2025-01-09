# frozen_string_literal: true

# Games::Participants::Form represents the {User} "Signature" form that becomes
# available at {Game} end.
class Games::Participants::Form
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def to_model = user

  def post_url = Router.game_participants_path(game)
  def cancel_url = Router.game_participants_path(game)

  private

  attr_reader :game,
              :user
end
