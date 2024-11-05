# frozen_string_literal: true

# Games::JustEnded::Update represents the update action for a {Game} that has
# just ended.
class Games::JustEnded::Update
  def initialize(current_game:)
    @current_game = current_game
  end

  def show
    Games::JustEnded::Show.new(current_game:)
  end

  private

  attr_reader :current_game
end
