# frozen_string_literal: true

# Users::Bests::Metrics::Efficiency
class Users::Bests::Metrics::Efficiency
  include Users::Bests::Metrics::Behaviors

  def beginner_value? = !!beginner_game
  def beginner_value = display(beginner_game&.efficiency)
  def beginner_url = url_for(beginner_game)

  def intermediate_value? = !!intermediate_game
  def intermediate_value = display(intermediate_game&.efficiency)
  def intermediate_url = url_for(intermediate_game)

  def expert_value? = !!expert_game
  def expert_value = display(expert_game&.efficiency)
  def expert_url = url_for(expert_game)

  private

  def beginner_game = @beginner_game ||= user_bests.beginner.efficiency

  def intermediate_game
    @intermediate_game ||= user_bests.intermediate.efficiency
  end

  def expert_game = @expert_game ||= user_bests.expert.efficiency

  def display(value)
    View.display(value) { View.percentage(it * 100.0) }
  end
end
