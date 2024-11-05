# frozen_string_literal: true

# Games::JustEnded::Footer
class Games::JustEnded::Footer
  def initialize(current_game:, user:)
    @current_game = current_game
    @user = user
  end

  def signature
    Games::Users::Signature.new(game: current_game, user:)
  end

  def results
    Games::Past::Results.new(game: current_game)
  end

  private

  attr_reader :current_game,
              :user
end
