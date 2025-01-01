# frozen_string_literal: true

# :reek:ModuleInitialize

# ConsoleObjectBehaviors is a mix-in that allows *::Console classes to act
# virtually indistinguishably like the object that they're wrapping, but to
# otherwise handle IRB Console-specific methods/logic in as a separate concern.
module ConsoleObjectBehaviors
  extend ActiveSupport::Concern

  included do
    # *::Console::Error represents any StandardError related to Console
    # processing on the including object.
    self::Error = Class.new(StandardError)

    define_singleton_method(:__class__) { module_parent }
    define_method(:__class__) { self.class.module_parent }

    try(:reflections)&.each do |name, reflection|
      next unless reflection.macro.in?(%i[has_one belongs_to])

      define_method(name) do
        result = __model__.public_send(name)
        result.try(:console) || result
      end
    end
  end

  class_methods do
    def method_missing(...)
      __class__.__send__(...)
    end

    # :reek:BooleanParameter
    # :reek:ManualDispatch
    def respond_to_missing?(method, include_private = true)
      __class__.respond_to?(method, include_private) || super
    end
  end

  def initialize(model)
    @model = model
  end

  # Prevent ObjectInspector from thinking of this object as a wrapper object.
  # This way, we can fully present ourself as if we are the original object
  # during object inspection.
  def to_model
    self
  end

  def __model__
    @model
  end

  private

  def method_missing(...)
    __model__.__send__(...)
  end

  # :reek:BooleanParameter
  # :reek:ManualDispatch
  def respond_to_missing?(method, include_private = true)
    __model__.respond_to?(method, include_private) || super
  end
end
