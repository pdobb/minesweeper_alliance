# frozen_string_literal: true

# CellTransaction records events transacted by {User}s on a {Cell} and when they
# occurred.
#
# @attr type [String] The Subclass name.
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr cell_id [Integer] References the {Cell} involved in this Transaction.
# @attr created_at [DateTime] When this Transaction occurred.
class CellTransaction < ApplicationRecord
  self.implicit_order_column = "created_at"

  include ConsoleBehaviors

  belongs_to :user

  belongs_to :cell
  has_one :game, through: :cell

  scope :for_user, ->(user) { where(user:) }

  scope :for_cell, ->(cell) { where(cell:) }
  scope :for_board, ->(board) { joins(:cell).merge(Cell.for_board(board)) }
  scope :for_game, ->(game) { joins(:cell).merge(Cell.for_game(game)) }

  def self.create_between(user:, cell:)
    new(user:, cell:).tap(&:save!)
  end

  # CellTransaction::Console acts like a {CellTransaction} but otherwise handles
  # IRB Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    private

    def inspect_info
      [
        [user.inspect, cell.inspect].join(" -> "),
        I18n.l(created_at, format: :debug),
      ].join(" @ ")
    end
  end
end
