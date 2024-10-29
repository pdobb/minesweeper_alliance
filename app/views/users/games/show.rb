# frozen_string_literal: true

# Users::Games::Show is a View Model for displaying the Games Show page in the
# context of a User.
#
# @see Games::Show
class Users::Games::Show < Games::Show
  def initialize(game:, user:)
    super(game:)
    @user = user
  end

  def nav
    Nav.new(game:, user:)
  end

  def display_name = user.display_name

  private

  attr_reader :user

  # Users::Games::Show::Nav is a View Model for handling navigation between
  # User-specific Game - Show pages.
  #
  # @see Games::Show::Nav
  class Nav < Games::Show::Nav
    def initialize(game:, user:)
      super(game:)
      @user = user
    end

    def show_close_button? = true

    def close_game_url(router = RailsRouter.instance)
      router.user_path(user)
    end

    def previous_game_url(router = RailsRouter.instance)
      router.user_game_path(user, previous_game)
    end

    def next_game_url(router = RailsRouter.instance)
      router.user_game_path(user, next_game)
    end

    def show_current_game_button? = false

    private

    attr_reader :game,
                :user

    def base_arel
      user.games.excluding(game).limit(1)
    end
  end
end
