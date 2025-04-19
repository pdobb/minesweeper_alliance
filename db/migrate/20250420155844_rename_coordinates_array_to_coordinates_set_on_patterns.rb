# frozen_string_literal: true

# Version: 20250420155844
class RenameCoordinatesArrayToCoordinatesSetOnPatterns <
        ActiveRecord::Migration[8.0]
  def change
    rename_column(:patterns, :coordinates_array, :coordinates_set)
  end
end
