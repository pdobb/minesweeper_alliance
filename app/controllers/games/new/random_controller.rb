# frozen_string_literal: true

class Games::New::RandomController < ApplicationController
  include Games::New::Behaviors

  def create
    find_or_create_current_game(settings: Board::Settings.random)
    redirect_to(root_path)
  end
end
