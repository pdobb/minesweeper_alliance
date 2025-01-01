# frozen_string_literal: true

# GameTransaction records events transacted by {User}s on a {Game} and when they
# occurred.
#
# @attr type [String] The Subclass name.
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr game_id [Integer] References the {Game} involved in this Transaction.
# @attr created_at [DateTime] When this Transaction occurred.
class GameTransaction < ApplicationRecord
  self.implicit_order_column = "created_at"

  include AbstractBaseClassBehaviors

  as_abstract_class

  belongs_to :user
  belongs_to :game

  scope :for_user, ->(user) { where(user:) }
  scope :for_game, ->(game) { where(game:) }

  validates :game, uniqueness: { scope: :type }

  # :reek:UnusedParameters
  def self.create_between(user:, game:)
    raise(NotImplementedError)
  end

  def self.exists_between?(user:, game:)
    for_user(user).for_game(game).exists?
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify

    def inspect_info
      [
        [user.inspect, game.inspect].join(" -> "),
        I18n.l(created_at, format: :debug),
      ].join(" @ ")
    end
  end
end
