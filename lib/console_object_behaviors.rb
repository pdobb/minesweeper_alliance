# frozen_string_literal: true

# :reek:ModuleInitialize

# ConsoleObjectBehaviors is a mix-in that allows *::Console classes to act
# virtually indistinguishably like the object that they're wrapping, but to
# otherwise handle IRB Console-specific methods/logic in as a separate concern.
module ConsoleObjectBehaviors
  extend ActiveSupport::Concern

  include ObjectInspector::InspectorsHelper

  included do
    delegate_missing_to(:@model)

    # *::Console::Error represents any StandardError related to Console
    # processing on the including object.
    self::Error = Class.new(StandardError)

    define_singleton_method(:__class__) { module_parent }
    define_method(:__class__) { self.class.module_parent }

    try(:reflections)&.each do |name, reflection|
      if reflection.macro.in?(%i[has_one belongs_to])
        define_method(name) do
          __model__.public_send(name).try(:console)
        end
      elsif reflection.macro == :has_many
        define_method(name) do
          __model__.public_send(name).by_most_recent.map { |record|
            record.try(:console)
          }
        end
      end
    end
  end

  class_methods do
    delegate_missing_to(:__class__)
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

  def __model__
    @model
  end

  private

  def inspect_identification(...) = __model__.identify(...)
end
