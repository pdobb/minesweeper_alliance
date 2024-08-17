# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :status, null: false, default: Game.status_in_progress
      t.index(
        :status,
        unique: true,
        where: "status = '#{Game.status_in_progress}'")

      t.timestamps
    end
  end
end
