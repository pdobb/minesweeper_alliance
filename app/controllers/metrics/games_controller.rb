# frozen_string_literal: true

class Metrics::GamesController < ApplicationController
  include AllowBrowserBehaviors

  def show
    if (game = Game.find_by(id: params[:id]))
      redirect_to(root_path) and return if game.on?

      @show = Metrics::Games::Show.new(game:, user: @user)
    else
      redirect_to(metrics_path, alert: t("flash.not_found", type: "Game"))
    end
  end
end
