# frozen_string_literal: true

# DifficultyLevel represents a number of playable {Game} types/options, and
# their associated {Board} settings. e.g. At the "Beginner" difficulty level,
# we create a Board of size 9x9 with 10 mines.
class DifficultyLevel
  include ObjectInspector::InspectorsHelper

  # DifficultyLevel::Error represents any StandardError related to
  # DifficultyLevel processing.
  Error = Class.new(StandardError)

  TEST = "Test"

  def self.settings_map
    @settings_map ||= {
      TEST => { columns: 3, rows: 3, mines: 1 },
      "Beginner" => { columns: 9, rows: 9, mines: 10 },
      "Intermediate" => { columns: 16, rows: 16, mines: 40 },
      "Expert" => { columns: 30, rows: 16, mines: 99 },
    }.tap { |hash|
      hash.except!(TEST) unless App.include_test_difficulty_level?
    }.freeze
  end

  attr_reader :name

  def self.all
    names.map { |name| new(name) }
  end

  def self.names
    settings_map.keys
  end

  def self.build_random
    new(names.sample)
  end

  def self.valid_name?(value)
    names.include?(value)
  end

  def initialize(name)
    name = name.to_s
    unless self.class.valid_name?(name)
      raise(
        Error,
        "got #{name.inspect}, expected one of: #{self.class.names.inspect}")
    end

    @name = name.titleize

    freeze
  end

  def to_s
    name
  end

  def initials
    name[0]
  end

  def dimensions
    "#{columns}x#{rows}"
  end

  def columns = settings.fetch(:columns)
  def rows = settings.fetch(:rows)
  def mines = settings.fetch(:mines)

  def settings
    self.class.settings_map.fetch(name)
  end

  private

  def inspect_identification = self.class.name
  def inspect_info = settings
  def inspect_name = name
end
