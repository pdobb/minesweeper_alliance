# frozen_string_literal: true

# Version: 20250222173153
class AddDevToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column(:users, :dev, :boolean, null: false, default: false)
    add_index(:users, :dev)
  end
end
