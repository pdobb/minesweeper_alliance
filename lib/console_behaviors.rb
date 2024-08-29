# frozen_string_literal: true

# ConsoleBehaviors is a mix-in that allows objects to easily define behaviors
# needed to convert themselves to their own *::Console objects.
#
# @see ConsoleObjectBehaviors
module ConsoleBehaviors
  def console = self.class::Console.new(self)
  alias_method :cons, :console
end
