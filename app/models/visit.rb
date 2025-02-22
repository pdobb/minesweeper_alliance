# frozen_string_literal: true

# Visit records a count of requests/visits to a given {#path}.
#
# @attr path [String]
# @attr count [Integer] The number of recorded visits to the named resource.
class Visit < ApplicationRecord
  validates :path,
            presence: true,
            uniqueness: true
  validates :count,
            presence: true,
            numericality: {
              integer: true,
              greater_than_or_equal_to: 0,
              allow_blank: true,
            }

  scope :for_path, ->(path) { where(path:) }

  scope :by_count, -> { order(count: :desc) }
  scope :by_path, -> { order(:path) }

  def to_s
    "#{View.delimited_pluralize("Visit", count:)}: #{path}"
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify(:id)
    def inspect_info = "Count: #{count}"
    def inspect_name = path
  end
end
