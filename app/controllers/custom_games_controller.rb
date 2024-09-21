# frozen_string_literal: true

class CustomGamesController < ApplicationController
  include Games::CreateBehaviors

  def new
    @custom_difficulty_level = CustomDifficultyLevel.new
  end

  def create
    custom_difficulty_level =
      CustomDifficultyLevel.new(custom_difficulty_level_params)

    if custom_difficulty_level.valid?
      find_or_create_game(difficulty_level: custom_difficulty_level)
      redirect_to(root_path)
    else
      @custom_difficulty_level = custom_difficulty_level
      render(:new)
    end
  end

  private

  def custom_difficulty_level_params
    params.require(:custom_difficulty_level).permit(
      :width,
      :height,
      :mines)
  end
end
