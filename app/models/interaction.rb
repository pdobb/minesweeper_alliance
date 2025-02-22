# frozen_string_literal: true

# Interaction records a count of interactions with the named element, link,
# resource, ...
#
# @attr name [String] A unique name for the resource.
# @attr count [Integer] The number of recorded visits to the named resource.
class Interaction < ApplicationRecord
  validates :name,
            presence: true,
            uniqueness: true
  validates :count,
            presence: true,
            numericality: {
              integer: true,
              greater_than_or_equal_to: 0,
              allow_blank: true,
            }

  scope :for_name, ->(name) { where(name:) }

  scope :by_count, -> { order(count: :desc) }
  scope :by_name, -> { order(:name) }

  def to_s
    "#{View.pluralize(count, "Interaction")}: #{name}"
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify(:id)
    def inspect_info = "Count: #{count}"
    def inspect_name = name
  end
end
