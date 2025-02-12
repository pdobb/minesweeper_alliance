# frozen_string_literal: true

# Metrics::Engagements::Bests::NullListing implements the Null Pattern for
# {Metrics::Engagements::Bests::Listing} view models.
class Metrics::Engagements::Bests::NullListing
  def present? = false
  def game_score = View.no_value_indicator_tag
  def fleet_size = View.no_value_indicator_tag
  def game_url = nil
  def link_action = nil
  def turbo_frame_name = nil
end
