# frozen_string_literal: true

# Version: 20240911180310
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table(:users, id: :uuid) do |t|
      t.string(:username, index: true)

      t.timestamps
    end
  end
end
