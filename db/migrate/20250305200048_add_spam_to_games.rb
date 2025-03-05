# frozen_string_literal: true

# Version: 20250305200048
class AddSpamToGames < ActiveRecord::Migration[8.0]
  def change
    add_column(:games, :spam, :boolean, null: false, default: false)
    add_index(:games, :spam)
  end
end
