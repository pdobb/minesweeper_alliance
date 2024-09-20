# frozen_string_literal: true

# Games::New is a view model for displaying the Games New page.
class Games::New
  def difficulty_levels
    DifficultyLevel.wrap(
      ::DifficultyLevel.all.including(::RandomDifficultyLevel.new))
  end

  # Games::New::DifficultyLevel wraps {::DifficultyLevel#name}s, for display
  # of New-Game creation Buttons.
  class DifficultyLevel
    include WrapMethodBehaviors

    def initialize(difficulty_level)
      @difficulty_level = difficulty_level
    end

    def name = @difficulty_level.name

    def new_game_url(router = RailsRouter.instance)
      router.games_path(difficulty_level: name)
    end
  end
end
