require "active_support/concern"

# ViewBehaviors simplifies instantiation of View Models.
module ViewBehaviors
  extend ActiveSupport::Concern

  def initialize(object)
    @object = object
  end

  def to_model
    @object
  end

  def to_param
    @object.to_param
  end
end
