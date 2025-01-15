# frozen_string_literal: true

# Version: 20250115204046
class UpdateUniquenessConstraintsOnGameTransactions <
        ActiveRecord::Migration[8.0]
  def up
    remove_index(:game_transactions, %i[game_id type])

    add_index(
      :game_transactions,
      %i[game_id type],
      unique: true,
      where: "type != 'GameJoinTransaction'")

    add_index(
      :game_transactions,
      %i[game_id user_id type],
      unique: true,
      where: "type = 'GameJoinTransaction'")
  end

  def down
    remove_index(:game_transactions, %i[game_id user_id type])
    remove_index(:game_transactions, %i[game_id type])
    add_index(:game_transactions, %i[game_id type])
  end
end
