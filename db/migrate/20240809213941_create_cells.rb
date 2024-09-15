# frozen_string_literal: true

# 20240809213941
class CreateCells < ActiveRecord::Migration[7.1]
  def change
    create_table(:cells) do |t|
      t.references(:board, null: false, foreign_key: { on_delete: :cascade })
      t.jsonb(:coordinates, null: false, default: {})
      t.string(:value)
      t.boolean(:mine, null: false, default: false, index: true)
      t.boolean(:flagged, null: false, default: false, index: true)
      t.boolean(:highlighted, null: false, default: false, index: true)
      t.boolean(:revealed, null: false, default: false, index: true)

      t.timestamps
      t.index(:created_at)
    end

    add_index(:cells, :coordinates, using: :gin)

    reversible do |dir|
      dir.up do
        execute(<<~SQL.squish)
          CREATE UNIQUE INDEX unique_coordinates_per_board_index
          ON cells (board_id, (coordinates->>'x'), (coordinates->>'y'));
        SQL
      end
      dir.down do
        execute(<<~SQL.squish)
          DROP INDEX IF EXISTS unique_coordinates_per_board_index;
        SQL
      end
    end
  end
end
