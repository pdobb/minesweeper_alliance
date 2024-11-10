# frozen_string_literal: true

# Games::New::Custom::New represents the "New Custom Game" page.
class Games::New::Custom::New
  def initialize(settings: Board::Settings.new)
    @settings = settings
  end

  def turbo_frame_name = Games::New::Content.turbo_frame_name

  def new_game_content
    Games::New::Content.new
  end

  def form(context:)
    Games::New::Custom::Form.new(settings:, context:)
  end

  private

  attr_reader :settings
end
