# frozen_string_literal: true

# ObjectInspectionBehaviors is an interface layer to the inspection helper in
# the object_inspector gem. Using this approach, we are able to e.g.
# conditionally enable object_inspector throughout the entire app.
module ObjectInspectionBehaviors
  extend ActiveSupport::Concern

  included do
    alias_method :original_inspect, :inspect

    include ObjectInspector::InspectorsHelper
  end

  def introspect
    self
  end
end
