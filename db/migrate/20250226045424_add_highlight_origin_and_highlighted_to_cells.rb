# frozen_string_literal: true

# Version: 20250226045424
class AddHighlightOriginAndHighlightedToCells < ActiveRecord::Migration[8.0]
  def change
    add_column(
      :cells,
      :highlight_origin,
      :boolean,
      null: false,
      default: false,
    )
    add_column(
      :cells,
      :highlighted,
      :boolean,
      null: false,
      default: false,
    )
  end
end
