# frozen_string_literal: true

# User represents all of:
# 1. A simple browser session.
# 2. A passive participant ("observer") of the current {Game} / War Room.
# 2. An "active participant" of the current {Game} / War Room.
#
# @attr id [GUID] a.k.a. "User Token"
# @attr username [String]
# @attr time_zone [String]
# @attr user_agent [String] The `request.user_agent` value at User creation.
class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  TRUNCATED_ID_RANGE = (-4..)
  USERNAME_MAX_LEGNTH = 26

  include ConsoleBehaviors

  has_many :user_update_transactions, dependent: :delete_all

  # Games that were joined in on by this User--in any fashion.
  # (Whether or not they were actively participated in by this User).
  has_many :participant_transactions
  has_many :games, through: :participant_transactions

  # Games that were joined in on, but never actively participated in by this
  # User.
  has_many :passive_participant_transactions,
           -> { is_passive },
           inverse_of: :user,
           class_name: "ParticipantTransaction"
  has_many :observed_games,
           through: :passive_participant_transactions,
           source: :game

  # Games that were actively participated in by this User.
  has_many :active_participant_transactions,
           -> { is_active },
           inverse_of: :user,
           class_name: "ParticipantTransaction"
  has_many :actively_participated_in_games,
           through: :active_participant_transactions,
           source: :game

  has_many :game_transactions, dependent: :nullify
  has_many :game_create_transactions
  has_many :game_start_transactions
  has_many :game_end_transactions

  has_many :cell_transactions, dependent: :nullify
  has_many :cell_reveal_transactions
  has_many :cell_chord_transactions
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  has_many :revealed_cells,
           -> { distinct },
           through: :cell_reveal_transactions,
           source: :cell

  scope :for_token, ->(token) { where(id: token) }
  scope :for_tokenish, ->(token) { where("id::text LIKE ?", "%#{token}") }
  scope :for_username, ->(username) {
    where("username LIKE ?", "%#{username}%")
  }
  scope :for_game, ->(game) { joins(:games).merge(Game.for_id(game)) }
  scope :for_game_as_observer, ->(game) {
    joins(:observed_games).merge(Game.for_id(game)).distinct
  }
  scope :for_game_as_active_participant, ->(game) {
    joins(:actively_participated_in_games).merge(Game.for_id(game)).distinct
  }
  scope :for_prune, -> {
    where(created_at: ..1.day.ago).
      where.missing(:cell_transactions)
  }

  scope :by_joined_at_asc, -> {
    joins(:games).merge(ParticipantTransaction.by_least_recent)
  }
  scope :by_participated_at_asc, -> {
    joins(:actively_participated_in_games).
      merge(ParticipantTransaction.by_started_actively_participating_at_asc)
  }

  validates :username,
            length: { maximum: USERNAME_MAX_LEGNTH }

  def token = id

  def username=(value)
    super(value.to_s.strip.presence)
  end

  def display_name
    [
      mms_id,
      username_in_database&.inspect,
    ].tap(&:compact!).join(" ")
  end

  def mms_id = "MMS-#{unique_id}"

  def unique_id
    @unique_id ||= created_at.to_i.to_s[TRUNCATED_ID_RANGE]
  end

  def active_participant_in?(game:)
    active_participant_transactions.for_game(game).exists?
  end

  def signer? = username?

  # :reek:NilCheck

  def signer_status_just_changed?
    username_previously_was.nil? || username.nil?
  end

  def completed_games_count
    actively_participated_in_games.for_game_over_statuses.size
  end

  def bests = @bests ||= Bests.new(self)

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect(limit: 5)
      {
        self => {
          profile_updates:
            user_update_transactions.
              by_most_recent.
              limit(limit).
              map(&:change_set),
          games: games.by_most_recent.limit(limit),
        },
      }
    end

    private

    def inspect_identification = identify(:truncated_id)
    def truncated_id = id[TRUNCATED_ID_RANGE]

    def inspect_info = time_zone
  end

  # User::Bests is a specialization on User for finding "best" (e.g.
  # top-scoring) {Game}s.
  class Bests
    def initialize(user)
      @user = user
    end

    def beginner_score = _score_arel.for_beginner_type.take
    def intermediate_score = _score_arel.for_intermediate_type.take
    def expert_score = _score_arel.for_expert_type.take

    def beginner_bbbvps = _bbbvps_arel.for_beginner_type.take
    def intermediate_bbbvps = _bbbvps_arel.for_intermediate_type.take
    def expert_bbbvps = _bbbvps_arel.for_expert_type.take

    def beginner_efficiency = _efficiency_arel.for_beginner_type.take
    def intermediate_efficiency = _efficiency_arel.for_intermediate_type.take
    def expert_efficiency = _efficiency_arel.for_expert_type.take

    private

    attr_reader :user

    def games = user.actively_participated_in_games
    def _score_arel = games.by_score_asc
    def _bbbvps_arel = games.by_bbbvps_desc
    def _efficiency_arel = games.by_efficiency_desc
  end

  # User::Prune handles removing all pruneable {User}s from the database.
  # Pruneable {Users}:
  # - are at least a day old, and
  # - have no {CellTransaction}s.
  #
  # @example
  #   User::Prune.call
  #
  # @example Dry Run
  #   User::Prune.dry_run
  module Prune
    def self.count = base_arel.count
    def self.user_agents_tally = base_arel.pluck(:user_agent).tally

    def self.call
      decorate do
        base_arel.each do |user|
          user.destroy
          Say.success("Pruned: #{describe(user)}")
        end
      end
    end

    def self.dry_run
      decorate do
        base_arel.each { |user| Say.info("Will prune: #{describe(user)}") }
      end
    end

    class << self
      private

      def base_arel = User.for_prune.by_least_recent

      def decorate
        Say.silent("Pruning #{count} stale Users") do
          Say.(user_agents_tally)

          results_count = yield.size

          Say.info("No stale Users found.") if results_count.zero?
        end

        self
      end

      def describe(user) = user.identify(:id, :created_at, :user_agent)
    end
  end
end
