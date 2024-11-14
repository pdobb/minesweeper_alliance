# frozen_string_literal: true

# Version: 20241112041937
class CreateGameTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table(:game_transactions) do |t|
      t.string(:type, null: false, index: true)
      t.references(
        :user, type: :uuid, foreign_key: { on_delete: :nullify }, index: true)
      t.references(
        :game, null: false, foreign_key: { on_delete: :cascade })
      t.text(:audit, null: false)

      t.datetime(:created_at, null: false, index: true)
    end

    add_index(:game_transactions, %i[game_id type], unique: true)
  end
end
