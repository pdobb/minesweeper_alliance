# frozen_string_literal: true

# User::Bests provides methods for finding the "best" (e.g. top-scoring) {Game}s
# that a given {User} has actively participated in.
class User::Bests
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
