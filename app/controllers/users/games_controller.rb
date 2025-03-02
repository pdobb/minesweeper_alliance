# frozen_string_literal: true

class Users::GamesController < ApplicationController
  include AllowBrowserBehaviors

  before_action :require_user
  before_action :require_game, only: :show

  def index
    show = Users::Show.new(user:)
    @index = show.games_index(context: layout)
  end

  def show
    @show = Users::Games::Show.new(game:, user:)
  end

  private

  attr_accessor :user,
                :game

  def require_user
    if (user = User.find_by(id: params[:user_id]))
      self.user = user
    else
      redirect_to(root_path, alert: t("flash.not_found", type: "User"))
    end
  end

  def require_game
    if (game = Game.find_by(id: params[:id]))
      redirect_to(root_path) and return if game.on?

      self.game = game
    else
      redirect_to(user_path(user), alert: t("flash.not_found", type: "Game"))
    end
  end
end
