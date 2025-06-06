# frozen_string_literal: true

class Games::New::RandomController < ApplicationController
  after_action RecordVisit

  def create
    settings = Board::Settings.random
    context = GamesController::CurrentGameContext.new(self)
    Game::Current.(settings:, context:)

    redirect_to(root_path)
  end
end
