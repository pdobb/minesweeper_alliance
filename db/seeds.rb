# frozen_string_literal: true

# This file should ensure the existence of records required to run the
# application in every environment (production, development, test). The code
# here should be idempotent so that it can be executed at any point in every
# environment.The data can then be loaded with the bin/rails db:seed command (or
# created alongside the database with db:setup).

pattern =
  Pattern.find_or_create_by!(name: "Ruby") { |new_pattern|
    new_pattern.settings = { width: 18, height: 15 }
    # rubocop:disable all
    new_pattern.coordinates_array = [
      [3, 1], [4, 1], [5, 1], [6, 1], [7, 1], [8, 1], [9, 1], [10, 1], [11, 1], [12, 1], [13, 1], [14, 1],
      [2, 2], [6, 2], [11, 2], [15, 2],
      [1, 3], [5, 3], [12, 3], [16, 3],
      [1, 4], [4, 4], [13, 4], [16, 4],
      [1, 5], [2, 5], [3, 5], [4, 5], [5, 5], [6, 5], [7, 5], [8, 5], [9, 5], [10, 5], [11, 5], [12, 5], [13, 5], [14, 5], [15, 5], [16, 5],
      [1, 6], [3, 6], [14, 6], [16, 6],
      [2, 7], [4, 7], [13, 7], [15, 7],
      [3, 8], [5, 8], [12, 8], [14, 8],
      [4, 9], [6, 9], [11, 9], [13, 9],
      [5, 10], [7, 10], [10, 10], [12, 10],
      [6, 11], [8, 11], [9, 11], [11, 11],
      [7, 12], [10, 12],
      [8, 13], [9, 13]
    ]
    # rubocop:enable all
  }
created_or_updated = pattern.just_created? ? "Created" : "Updated"
puts(" -> #{created_or_updated} #{pattern.inspect}")
