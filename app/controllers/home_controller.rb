# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    @view =
      if (current_game = Game.current)
        Games::Show.new(game: current_game)
      else
        Games::New.new
      end
  end
end
