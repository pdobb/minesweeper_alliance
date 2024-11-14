# frozen_string_literal: true

# CellTransaction records events transacted by {User}s on a {Cell} and when they
# occurred.
#
# @attr type [String] The Subclass name.
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr cell_id [Integer] References the {Cell} involved in this Transaction.
# @attr audit [String] An audit of relevant objects involved in the creation of
#   this record.
# @attr created_at [DateTime] When this Transaction occurred.
class CellTransaction < ApplicationRecord
  self.implicit_order_column = "created_at"

  UNIQUE_TYPES = %w[CellChordTransaction CellRevealTransaction].freeze

  include AbstractBaseClassBehaviors
  include ConsoleBehaviors

  as_abstract_class

  serialize :audit, coder: Audit

  belongs_to :user

  belongs_to :cell
  has_one :game, through: :cell

  scope :for_user, ->(user) { where(user:) }

  scope :for_cell, ->(cell) { where(cell:) }
  scope :for_board, ->(board) { joins(:cell).merge(Cell.for_board(board)) }
  scope :for_game, ->(game) { joins(:cell).merge(Cell.for_game(game)) }

  validates :cell,
            uniqueness: { scope: :type, if: -> { type.in?(UNIQUE_TYPES) } }
  validates :audit, presence: { on: :create }

  def self.create_between(user:, cell:)
    new(user:, cell:).tap { |new_game_transaction|
      new_game_transaction.audit = Audit.new(user: user.audit)
      new_game_transaction.save!
    }
  end

  def self.exists_between?(user:, cell:)
    for_user(user).for_cell(cell).exists?
  end

  def user_audit
    audit[:user]
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
