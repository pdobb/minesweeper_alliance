# frozen_string_literal: true

# ObjectInspectionBehaviors is an interface layer to the inspection helper in
# the object_inspector gem + other object inspection related behaviors.
module ObjectInspectionBehaviors
  include ObjectInspector::InspectBehaviors

  def introspect
    self
  end
end
