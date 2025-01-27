# frozen_string_literal: true

# Version: 20250127005408
class RemoveHighlightedFromCells < ActiveRecord::Migration[8.0]
  def up
    remove_column(:cells, :highlighted, :boolean)
  end

  def down
    add_column(
      :cells,
      :highlighted,
      :boolean,
      null: false,
      default: false)

    add_index(:cells, :highlighted)
  end
end
