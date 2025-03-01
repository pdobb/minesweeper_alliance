# frozen_string_literal: true

# Users::Games::ListingsGroup::Listing is a specialization on
# {Games::Index::ListingsGroup} that represents an individual {Game} listing
# on the User Show page's "Engagements" section.
class Users::Games::ListingsGroup::Listing <
        Games::Index::ListingsGroup::Listing
  def initialize(game, user:)
    super(game)
    @user = user
  end

  def game_url
    Router.user_game_path(user, game)
  end

  private

  attr_reader :user
end
