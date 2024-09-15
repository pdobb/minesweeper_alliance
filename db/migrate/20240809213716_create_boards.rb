# frozen_string_literal: true

# 20240809213716
class CreateBoards < ActiveRecord::Migration[7.1]
  def change
    create_table(:boards) do |t|
      t.references(:game, null: false, foreign_key: { on_delete: :cascade })
      t.jsonb(:settings, null: false, default: {})

      t.timestamps
      t.index(:created_at)
    end
  end
end
