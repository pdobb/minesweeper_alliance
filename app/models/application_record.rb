# frozen_string_literal: true

# ApplicationRecord is the base model for all Active Record models in the app.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ObjectInspector::InspectorsHelper

  scope :by_least_recent, -> { order(:id) } # rubocop:disable Rails/OrderById
end
