# frozen_string_literal: true

# Games::Current::Update represents the update action for the current {Game}.
class Games::Current::Update
  def initialize(current_game:)
    @current_game = current_game
  end

  def content
    Games::Current::Content.new(current_game:)
  end

  private

  attr_reader :current_game
end
