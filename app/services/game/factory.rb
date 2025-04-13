# frozen_string_literal: true

# Game::Factory provides object creation services for {Game}.
module Game::Factory
  # @return [Game] The newly created {Game} object.
  def self.create_for(...)
    build_for(...).tap { |new_game|
      Game.transaction do
        new_game.save!

        yield(new_game) if block_given?

        Board::Generate.(board: new_game.board)
      end
    }
  end

  # @attr settings [Board::Settings]
  #
  # @return [Game] The newly build {Game} object.
  def self.build_for(settings:)
    Game.new(type: settings.type).tap { |new_game|
      new_game.build_board(settings:)
    }
  end
end
