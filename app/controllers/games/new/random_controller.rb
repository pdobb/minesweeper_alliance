# frozen_string_literal: true

class Games::New::RandomController < ApplicationController
  def create
    settings = Board::Settings.random
    Game::Current.(settings:, user: current_user)

    redirect_to(root_path)
  end
end
