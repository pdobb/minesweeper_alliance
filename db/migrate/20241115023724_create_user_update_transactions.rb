# frozen_string_literal: true

# Version: 20241115023724
class CreateUserUpdateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table(:user_update_transactions) do |t|
      t.references(
        :user, type: :uuid, foreign_key: { on_delete: :cascade }, index: true
      )
      t.jsonb(:change_set, null: false)

      t.datetime(:created_at, null: false, index: true)
    end
  end
end
