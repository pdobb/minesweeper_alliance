# frozen_string_literal: true

# Games::Customs::New is a View Model for servicing the "New Custom Game"
# page/form.
class Games::Customs::New # rubocop:disable Style/ClassAndModuleChildren
  # Games::Customs::New::Form
  class Form
    STORAGE_KEY = :board_settings

    def initialize(board_settings, context:)
      @board_settings = board_settings
      @context = context
    end

    def to_model = @board_settings

    def value(name)
      current_value = to_model.public_send(name)
      return current_value if any_errors?

      previous_settings[name] || current_value
    end

    def ranges(name)
      Board::Settings::RANGES.fetch(name)
    end

    def any_errors? = to_model.errors.any?

    def display_errors
      to_model.errors.full_messages.join(", ")
    end

    private

    attr_reader :context

    def previous_settings
      @previous_settings ||=
        JSON.parse(cookies[STORAGE_KEY]).with_indifferent_access
    end

    def cookies = context.cookies
  end
end
