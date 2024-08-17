# frozen_string_literal: true

# ApplicationRecord is the base model for all Active Record models in the app.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ObjectInspector::InspectorsHelper
end
