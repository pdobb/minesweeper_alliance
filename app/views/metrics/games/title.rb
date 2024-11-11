# frozen_string_literal: true

# Metrics::Games::Title is a specialization on {Games::Title} that provides
# Metrics-specific {Game} paths.
class Metrics::Games::Title < Games::Title
  def game_absolute_url
    Router.metrics_game_url(game)
  end

  def game_url
    Router.metrics_game_path(game)
  end
end
