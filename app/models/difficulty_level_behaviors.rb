# frozen_string_literal: true

# DifficultyLevelBehaviors defines common code for DifficultyLevel objects.
module DifficultyLevelBehaviors
  extend ActiveSupport::Concern

  include ObjectInspector::InspectorsHelper

  def to_h
    { width:, height:, mines: }
  end

  def to_s
    name
  end

  def initials
    name[0]
  end

  def dimensions
    "#{width}x#{height}"
  end

  private

  def inspect_identification = self.class.name
  def inspect_info = to_h
  def inspect_name = name
end
