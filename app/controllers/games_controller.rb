# frozen_string_literal: true

class GamesController < ApplicationController
  def current
    if (current_game = Game.current)
      redirect_to(action: :show, id: current_game)
    else
      redirect_to(action: :new)
    end
  end

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
    if (current_game = Game.current)
      redirect_to(action: :show, id: current_game)
    else
      @view = Games::New.new
    end
  end

  def create
    current_game =
      Game.find_or_create_current(
        difficulty_level:
          Conversions.DifficultyLevel(params[:difficulty_level]))

    redirect_to(action: :show, id: current_game)
  end
end
