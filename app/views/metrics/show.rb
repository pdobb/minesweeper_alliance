# frozen_string_literal: true

# Metrics::Show is a View Model for displaying the Metrics Show page.
class Metrics::Show
  TOP_RECORDS_LIMIT = 5

  def engagements
    Metrics::Engagements.new
  end

  def participants
    Metrics::Participants.new
  end
end
