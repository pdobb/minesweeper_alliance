# frozen_string_literal: true

# Games::Users::Edit is a View Model for servicing the {User} "signing" form
# that shows at the end of a {Game} for participating {User}s.
class Games::Users::Edit
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::Users::Signature.new(game:, user:)
  end

  def form_model = user

  def update_form_url(router = RailsRouter.instance)
    router.game_user_path(game)
  end

  private

  attr_reader :game,
              :user
end
