# frozen_string_literal: true

# GameStartTransaction is a {GameTransaction} marking which {User} started the
# associated {Game}. Game "start" is when {Game#status} transitions from
# "Standing By" to "Sweep in Progress".
class GameStartTransaction < GameTransaction
  def self.create_between(user:, game:)
    user.game_start_transactions.build(game:).tap { |new_game_start_transaction|
      new_game_start_transaction.transaction do
        new_game_start_transaction.save!
        game.game_start_transaction = new_game_start_transaction

        # Cache Game start time onto Game itself, for easier querying.
        game.touch(:started_at, time: new_game_start_transaction.created_at)
      end
    }
  end
end
