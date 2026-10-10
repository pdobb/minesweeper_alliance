# frozen_string_literal: true

# Version: 20261009153000
class AddVersionToBoards < ActiveRecord::Migration[8.1]
  def change
    add_column(:boards, :version, :integer, null: false, default: 0)
  end
end
