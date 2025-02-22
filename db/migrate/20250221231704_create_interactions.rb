# frozen_string_literal: true

# Version: 20250221231704
class CreateInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table(:interactions) do |t|
      t.string(:name, null: false, index: { unique: true })
      t.integer(:count, null: false, default: 0)

      t.timestamps
    end
  end
end
