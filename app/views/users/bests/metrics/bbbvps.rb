# frozen_string_literal: true

# Users::Bests::Metrics::BBBVPS
class Users::Bests::Metrics::BBBVPS
  include Users::Bests::Metrics::Behaviors

  def beginner_value? = !!beginner_game
  def beginner_value = display(beginner_game&.bbbvps)
  def beginner_url = url_for(beginner_game)

  def intermediate_value? = !!intermediate_game
  def intermediate_value = display(intermediate_game&.bbbvps)
  def intermediate_url = url_for(intermediate_game)

  def expert_value? = !!expert_game
  def expert_value = display(expert_game&.bbbvps)
  def expert_url = url_for(expert_game)

  private

  def beginner_game = @beginner_game ||= user_bests.beginner.bbbvps
  def intermediate_game = @intermediate_game ||= user_bests.intermediate.bbbvps
  def expert_game = @expert_game ||= user_bests.expert.bbbvps

  def display(value)
    View.display(value) { View.round(it) }
  end
end
