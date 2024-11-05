# frozen_string_literal: true

class CustomGamesController < ApplicationController
  include Games::CreateBehaviors

  def new
    @view = CustomGames::New.new
  end

  def create
    settings = Board::Settings.custom(**settings_params.to_h.symbolize_keys)

    if settings.valid?
      find_or_create_game(settings:)
      redirect_to(root_path)
    else
      @view = CustomGames::New.new(settings:)
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def settings_params
    params.require(:board_settings).permit(
      :width,
      :height,
      :mines)
  end
end
