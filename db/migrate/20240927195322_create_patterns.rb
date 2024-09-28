# frozen_string_literal: true

# Version: 20240927195322
class CreatePatterns < ActiveRecord::Migration[7.2]
  def change
    create_table(:patterns) do |t|
      t.string(:name, null: false, index: { unique: true })
      t.jsonb(:settings, null: false, default: {})
      t.jsonb(:coordinates_array, null: false, default: [])

      t.timestamps
      t.index(:created_at)
    end
  end
end
