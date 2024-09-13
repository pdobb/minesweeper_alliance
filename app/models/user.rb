# frozen_string_literal: true

# User represents a player or observer of Minesweeper Alliance.
#
# @attr id [GUID] a.k.a. "User Token"
# @attr username [String]
class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  include ConsoleBehaviors

  has_many :cell_transactions, dependent: :nullify
  has_many :cell_reveal_transactions
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  has_many :games, -> { distinct }, through: :cell_transactions

  def display_name
    username || "Unknown User"
  end

  # User::Console acts like a {User} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    TRUNCATED_ID_RANGE = (-7..)

    include ConsoleObjectBehaviors

    private

    def inspect_identification
      identify(:truncated_id, klass: __class__)
    end

    def truncated_id = id[TRUNCATED_ID_RANGE]
  end
end
