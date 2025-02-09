# frozen_string_literal: true

# Users::Bests::Metrics::Score
class Users::Bests::Metrics::Score
  include Users::Bests::Metrics::Behaviors

  def beginner_value? = !!beginner_game
  def beginner_value = display(beginner_game&.score)
  def beginner_url = url_for(beginner_game)

  def intermediate_value? = !!intermediate_game
  def intermediate_value = display(intermediate_game&.score)
  def intermediate_url = url_for(intermediate_game)

  def expert_value? = !!expert_game
  def expert_value = display(expert_game&.score)
  def expert_url = url_for(expert_game)

  private

  def beginner_game = @beginner_game ||= user_bests.beginner.score
  def intermediate_game = @intermediate_game ||= user_bests.intermediate.score
  def expert_game = @expert_game ||= user_bests.expert.score

  def display(value)
    View.display(value) { View.round(it) }
  end
end
