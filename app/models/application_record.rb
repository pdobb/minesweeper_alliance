# frozen_string_literal: true

# ApplicationRecord is the base model for all Active Record models in the app.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :for_id, ->(id) { where(id:) }
  # Prefer `excluding(...)` over `not_for_id(...)`.

  # rubocop:disable Rails/OrderById
  scope :by_least_recent, -> { order(:id) }
  scope :by_most_recent, -> { order(id: :desc) }
  # rubocop:enable Rails/OrderById
end
