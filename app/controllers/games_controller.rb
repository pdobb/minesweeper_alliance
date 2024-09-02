# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @view =
      Games::Index.new(
        base_arel: Game.for_game_over_statuses.by_most_recently_ended)
  end

  def show
    if (game = Game.find_by(id: params[:id]))
      @view = Games::Show.new(game:)
    else
      redirect_to(action: :index, alert: t("flash.not_found", type: "Game"))
    end
  end

  def new
    @view = Games::New.new
  end

  def create
    current_game =
      Game.find_or_create_current(
        difficulty_level:
          Conversions.DifficultyLevel(params[:difficulty_level]))

    if current_game.just_created?
      DutyRoster.clear
      current_game.broadcast_refresh_to(:current_game)
    end

    redirect_to(root_path)
  end
end
