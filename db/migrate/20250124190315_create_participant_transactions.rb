# frozen_string_literal: true

# Version: 20250124190315
class CreateParticipantTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table(:participant_transactions) do |t|
      t.references(
        :user, type: :uuid, foreign_key: { on_delete: :nullify }, index: true
      )
      t.references(:game, null: false, foreign_key: { on_delete: :cascade })
      t.boolean(:active, null: false, default: false)
      t.datetime(:started_actively_participating_at)

      t.timestamps
    end

    add_index(:participant_transactions, %i[user_id game_id], unique: true)
    add_index(
      :participant_transactions,
      %i[active started_actively_participating_at],
    )
  end
end
