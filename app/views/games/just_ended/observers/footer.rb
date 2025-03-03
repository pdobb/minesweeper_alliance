# frozen_string_literal: true

# Games::JustEnded::Observers::Footer
class Games::JustEnded::Observers::Footer
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def results
    Games::JustEnded::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
