# frozen_string_literal: true

# Games::Current::ActivityIndicator represents the indicator light next to the
# War Room nav link.
#
# The indicator light is meant to convey:
# - Green -> A "Current {Game}" exists (and is {Game::Status#on?(...)} == true).
# - Gray  -> No "Current {Game}" exists.
#
# Note: A "Just Ended" {Game} is not a "Current {Game}".
class Games::Current::ActivityIndicator
  def turbo_target = "currentGameIndicator"

  def css
    active? ? "bg-green-500" : "bg-gray-500"
  end

  private

  def active? = Game::Current.exists?
end
