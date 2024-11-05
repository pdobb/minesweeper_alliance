# frozen_string_literal: true

# CustomGames::New represents the "New Custom Game" page.
class CustomGames::New
  def initialize(settings: Board::Settings.new)
    @settings = settings
  end

  def turbo_frame_name = Games::New.turbo_frame_name

  def new_game
    Games::New.new
  end

  def form(context:)
    CustomGames::Form.new(settings:, context:)
  end

  private

  attr_reader :settings
end
