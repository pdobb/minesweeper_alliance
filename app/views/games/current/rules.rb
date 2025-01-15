# frozen_string_literal: true

# :reek:RepeatedConditional

# Games::Current::Rules manages display of the game-play rules section (for the
# current {Game}).
class Games::Current::Rules
  def initialize(context:)
    @context = Context.new(context)
  end

  def collapse_container(context:)
    Games::Current::Rules::CollapseContainer.new(context:)
  end

  def reveal_method_descriptor
    mobile? ? "Tap" : "Click"
  end

  def flag_method_descriptor
    mobile? ? "Long Press" : "Right Click"
  end

  def reveal_neighbors_method_descriptor = reveal_method_descriptor

  private

  attr_reader :context

  def mobile? = context.mobile?

  # Games::Current::Rules::Context
  class Context
    def initialize(context)
      @context = context
    end

    def mobile? = @context.mobile?
  end
end
