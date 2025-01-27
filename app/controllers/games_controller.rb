# frozen_string_literal: true

class GamesController < ApplicationController
  include AllowBrowserBehaviors

  def index
    @view =
      Games::Index.new(
        base_arel: Game.for_game_over_statuses.by_most_recently_ended,
        context: layout)
  end

  def show
    if (game = Game.find_by(id: params[:id]))
      redirect_to(root_path) and return if game.on?

      @view = Games::Show.new(game:)
    else
      redirect_to({ action: :index }, alert: t("flash.not_found", type: "Game"))
    end
  end

  def new
    @view = Games::New.new
  end

  def create
    settings = Board::Settings.preset(params[:preset])
    Game::Current.(settings:, user: current_user)

    redirect_to(root_path)
  end
end
