# frozen_string_literal: true

# :reek:ModuleInitialize

# ActiveModelWrapperBehaviors is a mix-in for making View models quack like the
# ActiveModel objects they wrap.
#
# Usage: Including models must define #to_model.
#
# @example
#   class Games::Cell
#     include ActiveModelWrapperBehaviors
#
#     def initialize(model)
#       @model = model
#     end
#
#     private
#
#     def to_model = @model
#   end
#
#   Greet.("World") # => "Hello, World!"
module ActiveModelWrapperBehaviors
  private

  def to_model
    raise NotImplementedError
  end

  def to_param = to_model.to_param
  def to_partial_path = to_model.to_partial_path
end
