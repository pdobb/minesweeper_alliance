# frozen_string_literal: true

class GamesController < ApplicationController
  include Games::CreateBehaviors

  def index
    @view =
      Games::Index.new(
        base_arel: Game.for_game_over_statuses.by_most_recently_ended)
  end

  def show
    if (game = Game.find_by(id: params[:id]))
      @view = Games::Show.new(game:)
    else
      redirect_to({ action: :index }, alert: t("flash.not_found", type: "Game"))
    end
  end

  def new
    @view = Games::New.new
  end

  def create
    find_or_create_game(settings: Board::Settings.preset(params[:preset]))
    redirect_to(root_path)
  end
end
