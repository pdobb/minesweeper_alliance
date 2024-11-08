# frozen_string_literal: true

# Metrics::Games::Show represents past {Game}s in the context of the Metrics
# Show page.
class Metrics::Games::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def game_number = game.display_id

  def turbo_frame_name = Games::Past::Show.turbo_frame_name

  def cache_key(context:)
    [
      :metrics,
      game,
      context.mobile? ? :mobile : :web,
    ]
  end

  def content
    Metrics::Games::Content.new(game:)
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
