# frozen_string_literal: true

# Version: 20250221001444
class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table(:visits) do |t|
      t.text(:path, null: false, index: { unique: true })
      t.integer(:count, null: false, default: 0)

      t.timestamps
    end
  end
end
