# frozen_string_literal: true

# User represents a player or observer of Minesweeper Alliance.
#
# @attr id [GUID] a.k.a. "User Token"
# @attr username [String]
class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  TRUNCATED_ID_RANGE = (-4..)
  USERNAME_MAX_LEGNTH = 26

  include ConsoleBehaviors

  has_many :cell_transactions, dependent: :nullify
  has_many :cell_reveal_transactions
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  has_many :games, -> { distinct }, through: :cell_transactions

  validates :username,
            length: { maximum: USERNAME_MAX_LEGNTH }

  def username=(value)
    super(value.to_s.strip.presence)
  end

  def display_name
    [
      "MMS-#{unique_id}",
      username_in_database&.inspect,
    ].tap(&:compact!).join(" ")
  end

  def unique_id
    @unique_id ||= created_at.to_i.to_s[TRUNCATED_ID_RANGE]
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
