# frozen_string_literal: true

class RandomGamesController < ApplicationController
  include Games::CreateBehaviors

  def create
    difficulty_level = DifficultyLevel.build_random

    find_or_create_game(difficulty_level:)
    redirect_to(root_path)
  end
end
