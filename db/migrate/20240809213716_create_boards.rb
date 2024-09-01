# frozen_string_literal: true

# 20240809213716
class CreateBoards < ActiveRecord::Migration[7.1]
  def change
    create_table :boards do |t|
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.integer :columns
      t.integer :rows
      t.integer :mines

      t.timestamps
      t.index(:created_at)
    end
  end
end
