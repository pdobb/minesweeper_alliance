# frozen_string_literal: true

# CustomGames::Form represents the "New Custom Game" form.
class CustomGames::Form
  STORAGE_KEY = :board_settings

  def initialize(settings:, context:)
    @settings = settings
    @context = context
  end

  def to_model = @settings
  def post_url = Router.custom_game_path

  def value(name)
    current_value = to_model.public_send(name)
    return current_value if any_errors?

    previous_settings[name] || current_value
  end

  def ranges(key)
    Board::Settings::RANGES.fetch(key)
  end

  def any_errors? = to_model.errors.any?

  def display_errors
    to_model.errors.full_messages.join(", ")
  end

  private

  attr_reader :context

  def previous_settings
    @previous_settings ||=
      JSON.parse(cookies[STORAGE_KEY] || "{}").with_indifferent_access
  end

  def cookies = context.cookies
end
