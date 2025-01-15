# frozen_string_literal: true

# GameCreateTransaction is a {GameTransaction} marking which {User} created the
# associated {Game}.
class GameCreateTransaction < GameTransaction
  validates :game, uniqueness: { scope: :type }

  def self.create_between(user:, game:)
    user.game_create_transactions.build(game:).
      tap { |new_game_create_transaction|
        new_game_create_transaction.transaction do
          new_game_create_transaction.save!
          game.game_create_transaction = new_game_create_transaction
        end
      }
  end
end
