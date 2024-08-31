# frozen_string_literal: true

# :reek:ModuleInitialize

# ConsoleObjectBehaviors is a mix-in that allows *::Console classes to act
# virtually indistinguishably like the object that they're wrapping, but to
# otherwise handle IRB Console-specific methods/logic in as a separate concern.
module ConsoleObjectBehaviors
  extend ActiveSupport::Concern

  include ObjectInspector::InspectorsHelper

  included do
    # *::Console::Error represents any StandardError related to Console
    # processing on the including object.
    self::Error = Class.new(StandardError)
  end

  def initialize(model)
    @model = model
  end

  # Among other similar reasons, we do this to prevent ObjectInspector from
  # thinking of this object as a wrapper. This way, we can fully present ourself
  # as if we are the original object.
  def to_model
    self
  end

  def __to_model__
    @model
  end

  private

  def method_missing(method, ...)
    @model.__send__(method, ...)
  end

  # :reek:BooleanParameter
  # :reek:ManualDispatch

  def respond_to_missing?(method, include_private = true)
    @model.respond_to?(method, include_private) || super
  end

  def inspect_identification(...) = @model.identify(...)
end
