# frozen_string_literal: true

# :reek:ModuleInitialize

# Users::Bests::Metrics::Behaviors
module Users::Bests::Metrics::Behaviors
  NO_VALUE_INDICATOR_CONTAIENR_CSS = "text-dim-lg"

  include Games::Past::ActiveLinkBehaviors

  def initialize(user:, user_bests:)
    @user = user
    @user_bests = user_bests
  end

  def beginner_table_cell_css
    NO_VALUE_INDICATOR_CONTAIENR_CSS unless beginner_value?
  end

  def intermediate_table_cell_css
    NO_VALUE_INDICATOR_CONTAIENR_CSS unless intermediate_value?
  end

  def expert_table_cell_css
    NO_VALUE_INDICATOR_CONTAIENR_CSS unless expert_value?
  end

  private

  attr_reader :user,
              :user_bests

  def url_for(game)
    Router.user_game_path(user, game) if game
  end
end
