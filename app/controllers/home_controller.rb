# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    @view = Home::Show.new(current_game:)
  end

  private

  def current_game = Game.current
end
