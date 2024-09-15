# frozen_string_literal: true

# ConsoleBehaviors is a mix-in that allows objects to easily define behaviors
# needed to convert themselves to their own *::Console objects.
#
# @see ConsoleObjectBehaviors
module ConsoleBehaviors
  extend ActiveSupport::Concern

  included do
    private_class_method :call_method_chain
  end

  class_methods do
    # :reek:ManualDispatch
    # :reek:TooManyStatements

    # @example Given: A single method.
    #   Cell.cons("all")
    #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
    #
    # @example Given: A method chain.
    #   Cell.cons("is_not_flagged.is_not_revealed")
    #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
    #
    #   Cell.cons(%i[is_not_flagged is_not_revealed])
    #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
    #
    #   Cell.cons("first")
    #   # => <Cell[2](◻️) (0, 0) :: nil>
    def console(method_chain, context: self)
      result = call_method_chain(method_chain, context:)
      array =
        Array(result).map { |object|
          object.respond_to?(:console) ? object.console : object
        }
      array.one? ? array.first : array
    end
    alias_method :cons, :console

    def call_method_chain(method_chain, context: self)
      methods =
        case method_chain
        when String, Symbol then method_chain.to_s.split(".")
        else Array.wrap(method_chain)
        end

      methods.inject(context) { |object, method_name|
        object.__send__(method_name)
      }
    end
  end

  # @example
  #   Cell.first.cons
  #   # => <Cell[1](◻️ / 💣) (0, 0) :: nil>
  #
  # @example Given: A single method.
  #   Cell.first.cons("neighbors")
  #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
  #
  # @example Given: A method chain.
  #   Cell.first.cons("neighbors.is_not_revealed")
  #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
  #
  #   Cell.first.cons(%i[neighbors is_not_revealed])
  #   # => [<Cell[2](◻️) (1, 0) :: nil>, ...]
  #
  #   Cell.first.cons("neighbors.is_not_revealed.first")
  #   # => <Cell[2](◻️) (1, 0) :: nil>
  #
  # @example Given: A private method.
  #   Cell.first.cons("determine_revealed_value")
  #   # => "💣"
  def console(method_chain = nil)
    if method_chain
      self.class.console(method_chain, context: self)
    else
      self.class::Console.new(self)
    end
  end

  alias_method :cons, :console
end
