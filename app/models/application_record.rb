# frozen_string_literal: true

# ApplicationRecord is the base model for all Active Record models in the app.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :for_id, ->(id) { where(id:) }
  # Prefer `excluding(...)` over `not_for_id(...)`.

  scope :by_least_recent, -> { order(:created_at) }
  scope :by_most_recent, -> { order(created_at: :desc) }

  scope :by_random, -> { reorder("RANDOM()") }

  def just_created?
    id_previously_changed?
  end
end
