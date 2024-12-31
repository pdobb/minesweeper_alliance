# frozen_string_literal: true

# Metrics::Games::Container represents past {Game}s in the context of the
# Metrics Show page.
class Metrics::Games::Container
  def initialize(game:)
    @game = game
  end

  def game_number = game.display_id

  def turbo_frame_name = Games::Past::Container.display_case_turbo_frame_name
  def cache_key = [:metrics, game]

  def content
    Metrics::Games::Content.new(game:)
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game
end
