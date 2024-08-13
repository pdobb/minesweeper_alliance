# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.timestamps
    end
  end
end
