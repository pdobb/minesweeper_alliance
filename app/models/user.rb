# frozen_string_literal: true

# :reek:TooManyMethods
# :reek:InstanceVariableAssumption

# User represents:
# 1. A passive participant ("observer") of the current {Game} / War Room.
# 2. An "active participant" of the current {Game} / War Room.
#
# Note: Just a simple browser session is likely represented as a {Guest},
# instead.
#
# @attr id [GUID] a.k.a. "User Token"
# @attr username [String]
# @attr time_zone [String] Sourced either automatically (browser detection / JS)
#   or manually (User selection).
# @attr user_agent [String] The `request.user_agent` value at time of creation.
# @attr authentication_token [String<UUID>] (<UUID>) a secret token for
#   re-authenticating a User after e.g. "signing out", switching browsers, etc.
#
# @see User::Guest
class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  DESIGNATION = "MMS" # Motor MineSweeper
  TRUNCATED_TOKENS_LENGTH = 4
  TRUNCATED_TOKENS_RANGE = (-TRUNCATED_TOKENS_LENGTH..)
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

  scope :is_dev, -> { where(dev: true) }

  scope :for_token, ->(token) { where(id: token) }
  scope :for_authentication_token, ->(authentication_token) {
    where(authentication_token:)
  }
  scope :for_game, ->(game) { joins(:games).merge(Game.for_id(game)) }
  scope :for_game_as_observer, ->(game) {
    joins(:observed_games).merge(Game.for_id(game)).distinct
  }
  scope :for_game_as_active_participant, ->(game) {
    joins(:actively_participated_in_games).merge(Game.for_id(game)).distinct
  }

  scope :by_joined_at_asc, -> {
    joins(:games).merge(ParticipantTransaction.by_least_recent)
  }
  scope :by_participated_at_asc, -> {
    joins(:actively_participated_in_games)
      .merge(ParticipantTransaction.by_started_actively_participating_at_asc)
  }

  validates :username,
            length: { maximum: USERNAME_MAX_LEGNTH }

  def token = id
  def identifier = username || internal_token

  def username=(value)
    super(value.to_s.strip.presence)
  end

  def display_name
    [
      mms_id,
      username_in_database&.inspect,
    ].tap(&:compact!).join(" ")
  end

  def mms_id = "#{DESIGNATION}-#{internal_token}"

  # Indicates that this not a {Guest} object.
  def participant? = true
  def active_participant? = active_participant_transactions.any?

  # :reek:NilCheck
  def active_participant_in?(game:)
    @active_participant_in ||= {}

    @active_participant_in.fetch(game) {
      @active_participant_in[game] =
        active_participant_transactions.for_game(game).any?
    }
  end

  def signer? = username?
  def not_a_signer? = !signer?
  def past_signer? = user_update_transactions.has_key_username.any?
  def ever_signed? = signer? || past_signer?

  # :reek:NilCheck

  def signer_status_just_changed?
    username_previously_was.nil? || username.nil?
  end

  def completed_games_count
    actively_participated_in_games.for_game_over_statuses.size
  end

  def bests
    @bests ||= User::Bests.new(self)
  end

  private

  def internal_token
    @internal_token ||= created_at.to_i.to_s[TRUNCATED_TOKENS_RANGE]
  end

  concerning :ObjectInspection do # rubocop:disable Metrics/BlockLength
    include ObjectInspectionBehaviors

    # rubocop:disable Metrics/AbcSize
    def introspect(limit: 5)
      {
        self => {
          profile_updates:
            user_update_transactions.by_most_recent.limit(limit)
              .pluck(:change_set),
          observed_games: observed_games.by_most_recent.limit(limit),
          actively_participated_in_games:
            actively_participated_in_games.by_most_recent.limit(limit),
          participant_transactions:
            participant_transactions.by_most_recent.limit(limit),
          game_transactions: game_transactions.by_most_recent.limit(limit),
          cell_transactions: cell_transactions.by_most_recent.limit(limit),
        },
      }
    end
    # rubocop:enable Metrics/AbcSize

    private

    def inspect_identification = identify(:truncated_id)
    def truncated_id = id[TRUNCATED_TOKENS_RANGE]

    def inspect_flags
      Emoji.dev if dev?
    end

    def inspect_issues(scope:)
      scope.complex? { "SPAMMER" if User::Type.spammer?(self) }
    end

    def inspect_info = time_zone || "NO_TIME_ZONE"
  end

  # User::Console acts like a {User} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    TRUNCATED_TOKENS_REGEX = /\A\d{#{TRUNCATED_TOKENS_LENGTH}}\z/

    scope :for_mms_id, ->(mms_id) {
      mms_id = mms_id.to_s.delete_prefix("#{DESIGNATION}-")
      return none unless mms_id.match?(TRUNCATED_TOKENS_REGEX)

      where("FLOOR(EXTRACT(EPOCH FROM created_at))::int % 10000 = ?", mms_id)
    }
    scope :like_token, ->(token) { where("id::text LIKE ?", "%#{token}") }
    scope :like_username, ->(username) {
      where("username LIKE ?", "%#{username}%")
    }

    def self.recover(value = nil)
      users =
        __class__
          .for_mms_id(value)
          .or(like_token(value))
          .or(like_username(value))

      users.map { |user|
        {
          user.identify(:mms_id, :username, :id) =>
            Router.current_user_account_authentication_url(
              token: user.authentication_token),
        }
      }
    end
  end
end
