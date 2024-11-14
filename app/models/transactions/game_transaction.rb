# frozen_string_literal: true

# GameTransaction records events transacted by {User}s on a {Game} and when they
# occurred.
#
# @attr type [String] The Subclass name.
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr game_id [Integer] References the {Game} involved in this Transaction.
# @attr audit [String] An audit of relevant objects involved in the creation of
#   this record.
# @attr created_at [DateTime] When this Transaction occurred.
class GameTransaction < ApplicationRecord
  self.implicit_order_column = "created_at"

  include AbstractBaseClassBehaviors
  include ConsoleBehaviors

  as_abstract_class

  serialize :audit, coder: Audit

  belongs_to :user
  belongs_to :game

  scope :for_user, ->(user) { where(user:) }
  scope :for_game, ->(game) { where(game:) }

  validates :game, uniqueness: { scope: :type }
  validates :audit, presence: { on: :create }

  def self.create_between(user:, game:)
    new(user:, game:).tap { |new_game_transaction|
      new_game_transaction.audit = Audit.new(user: user.audit)
      new_game_transaction.save!
    }
  end

  def self.exists_between?(user:, game:)
    for_user(user).for_game(game).exists?
  end

  def user_audit
    audit[:user]
  end

  # GameTransaction::Console acts like a {GameTransaction} but otherwise handles
  # IRB Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    private

    def inspect_info
      [
        [user.inspect, game.inspect].join(" -> "),
        I18n.l(created_at, format: :debug),
      ].join(" @ ")
    end
  end
end
