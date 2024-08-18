# frozen_string_literal: true

require "active_support/concern"

# :reek:ModuleInitialize

# ViewBehaviors simplifies instantiation of View Models.
module ViewBehaviors
  extend ActiveSupport::Concern

  def initialize(object)
    @object = object
  end

  def to_model = @object
  def to_param = to_model.to_param
  def to_partial_path = to_model.to_partial_path
end
