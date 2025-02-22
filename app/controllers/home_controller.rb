# frozen_string_literal: true

class HomeController < ApplicationController
  include AllowBrowserBehaviors

  after_action RecordVisit

  def show
    @view = Home::Show.new(current_game:)

    Game::Current::Join.(user: current_user, game: current_game) if current_game
  end

  private

  def current_game
    @current_game ||= Game::Current::Find.call
  end
end
