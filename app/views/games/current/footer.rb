# frozen_string_literal: true

# Games::Current::Footer represents the bottom portion of the current {Game}
# Show page.
class Games::Current::Footer
  def initialize(template)
    @template = template
  end

  def rules
    Games::Current::Rules.new(template)
  end

  private

  attr_reader :template
end
