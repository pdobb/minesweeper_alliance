# frozen_string_literal: true

class Users::GamesController < ApplicationController
  before_action :require_user, only: :show

  def show
    if (game = Game.find_by(id: params[:id]))
      redirect_to(root_path) and return if game.on?

      @view = Users::Games::Show.new(game:, user: @user)
    else
      redirect_to(user_path(@user), alert: t("flash.not_found", type: "Game"))
    end
  end

  private

  def require_user
    if (user = User.find_by(id: params[:user_id]))
      @user = user
    else
      redirect_to(root_path, alert: t("flash.not_found", type: "User"))
    end
  end
end
