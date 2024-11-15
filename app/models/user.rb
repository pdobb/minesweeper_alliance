# frozen_string_literal: true

# User represents a player or observer of Minesweeper Alliance.
#
# @attr id [GUID] a.k.a. "User Token"
# @attr username [String]
# @attr time_zone [String]
class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  TRUNCATED_ID_RANGE = (-4..)
  USERNAME_MAX_LEGNTH = 26

  include ConsoleBehaviors

  has_many :user_update_transactions, dependent: :delete_all

  has_many :game_transactions, dependent: :nullify
  has_many :game_create_transactions
  has_many :game_start_transactions
  has_many :game_end_transactions

  has_many :cell_transactions, dependent: :nullify
  has_many :cell_reveal_transactions
  has_many :cell_chord_transactions
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  has_many :games, -> { distinct }, through: :cell_transactions
  has_many :revealed_cells,
           -> { distinct },
           through: :cell_reveal_transactions,
           source: :cell

  validates :username,
            length: { maximum: USERNAME_MAX_LEGNTH }

  def username=(value)
    super(value.to_s.strip.presence)
  end

  def display_name
    [
      mms_id,
      username_in_database&.inspect,
    ].tap(&:compact!).join(" ")
  end

  def mms_id
    "MMS-#{unique_id}"
  end

  def unique_id
    @unique_id ||= created_at.to_i.to_s[TRUNCATED_ID_RANGE]
  end

  def signer? = username?

  # :reek:NilCheck

  def signer_status_just_changed?
    username_previously_was.nil? || username.nil?
  end

  def participated_in?(game)
    game.users.for_id(self).exists?
  end

  def completed_games_count
    games.for_game_over_statuses.size
  end

  def bests = @bests ||= Bests.new(self)

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

    def games = user.games
    def _score_arel = games.by_score_asc
    def _bbbvps_arel = games.by_bbbvps_desc
    def _efficiency_arel = games.by_efficiency_desc
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

    def inspect_info
      time_zone
    end

    def truncated_id = id[TRUNCATED_ID_RANGE]
  end
end
