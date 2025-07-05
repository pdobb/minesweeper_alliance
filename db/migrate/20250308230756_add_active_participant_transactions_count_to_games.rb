# frozen_string_literal: true

# Version: 20250308230756
class AddActiveParticipantTransactionsCountToGames <
        ActiveRecord::Migration[8.0]
  def up
    add_column(
      :games,
      :active_participants_count,
      :integer,
      null: false,
      default: 0,
    )
    add_index(:games, :active_participants_count)

    Game.reset_column_information
    Game.find_each do |game|
      game.update!(
        active_participants_count: game.active_participant_transactions.count,
      )
    end
  end

  def down
    remove_column(:games, :active_participants_count)
  end
end
