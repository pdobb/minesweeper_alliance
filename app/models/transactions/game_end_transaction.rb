# frozen_string_literal: true

# GameEndTransaction is a {GameTransaction} marking which {User} made the final
# move during the associated {Game}. Game "end" is when {Game#status}
# transitions from "Sweep in Progress" to either "Alliance Wins" or "Mines Win".
class GameEndTransaction < GameTransaction
  def self.create_between(user:, game:)
    user.game_end_transactions.build(game:).tap { |new_game_end_transaction|
      new_game_end_transaction.transaction do
        new_game_end_transaction.save!
        game.game_end_transaction = new_game_end_transaction

        # Cache Game start time onto Game itself, for easier querying.
        game.update_ended_at(time: new_game_end_transaction.created_at)
      end
    }
  end
end
