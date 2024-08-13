# frozen_string_literal: true

class CreateBoards < ActiveRecord::Migration[7.1]
  def change
    create_table :boards do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :columns
      t.integer :rows
      t.integer :mines

      t.timestamps
    end
  end
end
