# frozen_string_literal: true

# Games::Current::Footer represents the bottom portion of the current {Game}
# Show page.
class Games::Current::Footer
  def initialize(context)
    @context = context
  end

  def rules
    Games::Current::Rules.new(context)
  end

  private

  attr_reader :context
end
