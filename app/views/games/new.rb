# frozen_string_literal: true

# Games::New is a view model for displaying the Games New page.
class Games::New
  def difficulty_levels
    DifficultyLevel.wrap(::DifficultyLevel.all)
  end

  # Games::New::DifficultyLevel wraps {::DifficultyLevel#name}s, for display
  # of New-Game creation Buttons.
  class DifficultyLevel
    include Games::DifficultyLevelBehaviors

    def new_game_url(router = RailsRouter.instance)
      router.games_path(difficulty_level: name)
    end
  end
end
