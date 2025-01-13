# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::CurrentUser::Form represents the {User}
# "signature" form that shows at {Game} end for actively participating {User}s.
class Games::JustEnded::ActiveParticipants::CurrentUser::Form
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def to_model = user

  def post_url = Router.just_ended_game_current_user_path(game)
  def cancel_url = Router.just_ended_game_current_user_path(game)

  private

  attr_reader :game,
              :user
end