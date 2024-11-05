# frozen_string_literal: true

# Games::Users::Form represents the {User} "Signature" form that becomes
# available at {Game} end.
class Games::Users::Form
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def to_model = user
  def post_url = Router.game_user_path(game)

  private

  attr_reader :game,
              :user
end
