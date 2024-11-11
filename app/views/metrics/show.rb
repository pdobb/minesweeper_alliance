# frozen_string_literal: true

# Metrics::Show is a View Model for displaying the Metrics Show page.
class Metrics::Show
  def engagements
    Metrics::Engagements.new
  end
end
