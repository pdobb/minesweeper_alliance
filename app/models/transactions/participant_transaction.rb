# frozen_string_literal: true

# A ParticipantTransaction is a record of
# - when a {User} joins a {Game}, and
# - whether or not a {User} is currently considered to be a passive or active
#   participant in a {Game}.
#
# Upon joining a {Game}, {User}s are considered passive participants.
# Accordingly, a ParticipantTransaction record should be created in its default
# state (i.e. {#active} == false)--whether they created the {Game} or not.
#
# Upon performing their first {Cell} Action for each {Game}, a {User} changes
# from being a passive participant to being an active participant in that
# {Game}. Accordingly, the associated ParticipantTransaction record should be
# updated to be active (i.e. {#active} == true) for that {User} and {Game}.
#
# There can only be one ParticipantTransaction per {User} per {Game}.
#
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr game_id [Integer] References the {Game} involved in this Transaction.
# @attr active [Boolean] Whether the {User} is an active or a passive
#   participant in the associated {Game}.
# @attr started_actively_participating_at [DateTime] (nil) Timestamp of when
#   the associated {User} first started actively participating in the associated
#   {Game} (and {#active} was set to `true`).
class ParticipantTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :game

  scope :for_user, ->(user) { where(user:) }
  scope :for_game, ->(game) { where(game:) }

  scope :is_passive, -> { where(active: false) }
  scope :is_active, -> { where(active: true) }

  scope :by_started_actively_participating_at_asc, -> {
    order(:started_actively_participating_at)
  }

  validates :user, uniqueness: { scope: :game }

  def self.create_between(user:, game:)
    # We rely on our uniqueness validation to fail (without raising) if the
    # given {User} has already joined the given {Game} before.
    user.participant_transactions.create(game:)
  end

  def self.activate_between(user:, game:)
    find_between!(user:, game:).tap { |transaction|
      unless transaction.active?
        transaction.update!(
          active: true,
          started_actively_participating_at: Time.current)
      end
    }
  end

  def self.find_between!(user:, game:)
    for_user(user).for_game(game).take!
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      {
        self => [
          user.introspect,
          game.introspect,
        ],
      }
    end

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
