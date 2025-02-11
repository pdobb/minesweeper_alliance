# frozen_string_literal: true

# :reek:ModuleInitialize

# Users::Bests::Metrics::Behaviors
module Users::Bests::Metrics::Behaviors
  include Games::Past::ActiveLinkBehaviors

  def initialize(user:, user_bests:)
    @user = user
    @user_bests = user_bests
  end

  private

  attr_reader :user,
              :user_bests

  def url_for(game)
    Router.user_game_path(user, game) if game
  end
end
