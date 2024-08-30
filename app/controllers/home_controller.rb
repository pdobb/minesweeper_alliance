# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    if (current_game = Game.current)
      redirect_to(game_path(current_game))
    else
      redirect_to(new_game_path)
    end
  end
end
