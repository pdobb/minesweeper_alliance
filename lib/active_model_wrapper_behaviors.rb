# frozen_string_literal: true

# :reek:ModuleInitialize

# ActiveModelWrapperBehaviors is a mix-in for making View models quack like the
# ActiveModel objects they wrap.
#
# Usage: Including models must either:
# - Set the wrapped object to `@obect` in their initializer, or
# - Define #to_model
module ActiveModelWrapperBehaviors
  def initialize(object)
    @object = object
  end

  def to_model = @object
  def to_param = to_model.to_param
  def to_partial_path = to_model.to_partial_path
end
