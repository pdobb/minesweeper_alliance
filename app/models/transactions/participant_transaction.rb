# frozen_string_literal: true

# A ParticipantTransaction records:
# - A {User} having joined in on a {Game}, and
# - Whether or not the {User} is currently considered to be a
#   "passive participant" or an "active participant" in the {Game}.
#
# Creating a {Game} is considered to be active participation in that {Game}.
# This is partly just because it makes sense that this is an "active" action,
# but, also, it affords us a {User} to tie the {Game} creation event to.
# So, on-{Game}-create:
# 1. If the {Game} creator was a {Guest}, then a {User} record is created to
#    take its place,
# 2. A {GameCreateTransaction} is created for the {User}, and
# 3. An active ParticipantTransaction is created for the {User}.
#
# Upon simply joining (visiting) a {Game}:
# - {Guest}s are left alone, with no transactions being created to tie them to
#   the {Game} in any way.
# - {User}s are associated with the {Game} via a new ParticipantTransaction,
#   created in its default, passive state (i.e. {#active} == false).
#
# Otherwise, upon performing their first {Cell} Action for each {Game}:
# - {Guest}s are converted into {User}s, and
# - {User}s change from being passive participants to being active participants
#   in that {Game}. i.e. the ParticipantTransaction record is set to
#   {#active} == true for that {User} / {Game}.
#
# There can only be one ParticipantTransaction per {User} per {Game}.
#
# Note: A ParticipantTransaction is like a virtual role object, defining a
# short-lived "Participant" role that {User}s (but not {Guest}s) take on when
# participating in a {Game}.
#
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr game_id [Integer] References the {Game} involved in this Transaction.
# @attr active [Boolean] Whether the {User} is an active or a passive
#   participant in the associated {Game}.
# @attr started_actively_participating_at [DateTime] (nil) Timestamp of when
#   the associated {User} first started actively participating in the associated
#   {Game} (and {#active} was set to `true`).
#
# @see Game::Current::Create
# @see Game::Current::Join
# @see Games::Current::CreateParticipant
class ParticipantTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :user, uniqueness: { scope: :game }

  scope :for_user, ->(user) { where(user:) }
  scope :for_game, ->(game) { where(game:) }

  scope :is_passive, -> { where(active: false) }
  scope :is_active, -> { where(active: true) }

  scope :by_started_actively_participating_at_asc, -> {
    order(:started_actively_participating_at)
  }

  def self.create_between(user:, game:)
    # We rely on our uniqueness validation to fail (without raising) if the
    # given {User} has already participated in the given {Game} before.
    user.participant_transactions.create(game:)
  end

  def self.create_active_between(user:, game:)
    game.with_lock do
      user.participant_transactions.create(
        game:,
        active: true,
        started_actively_participating_at: Time.current,
      )
      game.increment!(:active_participants_count)
    end
  end

  def self.activate_between(user:, game:)
    find_between!(user:, game:).tap { |transaction|
      unless transaction.active?
        game.with_lock do
          transaction.update!(
            active: true,
            started_actively_participating_at: Time.current,
          )
          game.increment!(:active_participants_count)
        end
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

    def inspect_flags
      active? ? Emoji.ship : Emoji.anchor
    end
  end
end
