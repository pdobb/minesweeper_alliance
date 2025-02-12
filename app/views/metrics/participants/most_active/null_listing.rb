# frozen_string_literal: true

# Metrics::Participants::MostActive::NullListing implements the Null Pattern for
# {Metrics::Participants::MostActive::Listing}.
class Metrics::Participants::MostActive::NullListing
  def active_participation_count = View.no_value_indicator_tag
  def present? = false
  def name = View.no_value_indicator_tag
  def user_url = nil
  def title? = false
end
