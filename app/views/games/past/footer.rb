# frozen_string_literal: true

# Games::Past::Footer
class Games::Past::Footer
  def initialize(game:)
    @game = game
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game
end
