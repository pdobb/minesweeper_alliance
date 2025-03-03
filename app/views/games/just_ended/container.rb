# frozen_string_literal: true

# Games::JustEnded::Container represents the entire view context surrounding
# {Game}s that have just ended.
class Games::JustEnded::Container
  def initialize(game:)
    @game = game
  end

  def partial_path
    "games/just_ended/container"
  end

  def content
    Games::JustEnded::Content.new(game:)
  end

  def footer_partial_options(user:)
    Games::JustEnded::FooterPartialOptions.(game:, user:)
  end

  private

  attr_reader :game
end
