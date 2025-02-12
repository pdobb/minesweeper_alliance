# frozen_string_literal: true

# DevPortal::Patterns::Import::Form represents the inline for for Pattern
# Import.
class DevPortal::Patterns::Import::Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :new_pattern

  attribute :file

  validates :file,
            presence: true

  def import
    return false unless valid?

    @new_pattern = Pattern::Import.(path: file)
    return true if new_pattern.valid?

    errors.merge!(new_pattern.errors)
    false
  end

  def new_pattern_name = new_pattern.name
end
