# frozen_string_literal: true

class Games::New::RandomPatternController < ApplicationController
  def create
    settings = Board::Settings.random_pattern
    context = GamesController::CurrentGameContext.new(self)
    Game::Current.(settings:, context:)

    redirect_to(root_path)
  end
end
