# frozen_string_literal: true

# Users::Bests::Games::Show represents past {Game}s in the context of a
# participating player's ({User}'s) "Bests" ({Game}s).
class Users::Bests::Games::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def container
    Users::Bests::Games::Container.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
