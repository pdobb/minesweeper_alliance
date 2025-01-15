# frozen_string_literal: true

# GameJoinTransaction is a {GameTransaction} marking when a {User} joins (as in
# visits, views, or otherwise witnesses) a {Game}.
#
# There can only be one GameJoinTransaction for each
# {GameTransaction#type}-{User} pair per {Game}.
class GameJoinTransaction < GameTransaction
  validates :game, uniqueness: { scope: %i[user_id type] }

  def self.create_between(user:, game:)
    # We rely on our uniqueness validation to fail (without raising) if the
    # given {User} has already joined the given {Game} before.
    user.game_join_transactions.create(game:)
  end
end
