# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    @view = Home::Show.new(current_game: Game.current)
  end

  def about
  end
end
