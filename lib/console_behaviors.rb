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

    # @example Usage with: A single method.
    #   MyModel.cons("my_method")
    #
    # @example Usage with: A method chain.
    #   MyModel.cons("my_method_1.my_method2")
    #   MyModel.cons(%i[my_method_1 my_method2])
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
  #   MyModel.first.cons
  #   # => <MyModel[1](...) :: ...>
  #
  # @example Usage with: A single method.
  #   MyModel.first.cons("my_method")
  #
  # @example Usage with: A method chain.
  #   MyModel.first.cons("my_method1.my_method2")
  #   MyModel.first.cons(%i[my_method1 my_method2])
  #   MyModel.first.cons("my_method1.my_method2.my_method_3")
  #
  # @example Usage with: A private method.
  #   MyModel.first.cons("my_private_method")
  def console(method_chain = nil)
    if method_chain
      self.class.console(method_chain, context: self)
    else
      self.class::Console.new(self)
    end
  end

  alias cons console
end
