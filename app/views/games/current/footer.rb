# frozen_string_literal: true

# Games::Current::Footer represents the bottom portion of the current {Game}
# Show page.
class Games::Current::Footer
  def rules(context:)
    Games::Current::Rules.new(context:)
  end
end
