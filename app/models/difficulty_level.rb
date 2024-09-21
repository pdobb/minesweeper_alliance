# frozen_string_literal: true

# DifficultyLevel represents a number of playable {Game} types/options, and
# their associated {Board} settings. e.g. At the "Beginner" difficulty level,
# we create a Board of size 9x9 with 10 mines.
class DifficultyLevel
  include DifficultyLevelBehaviors

  # DifficultyLevel::Error represents any StandardError related to
  # DifficultyLevel processing.
  Error = Class.new(StandardError)

  def self.settings_map
    @settings_map ||= {
      "Beginner" => { width: 9, height: 9, mines: 10 },
      "Intermediate" => { width: 16, height: 16, mines: 40 },
      "Expert" => { width: 30, height: 16, mines: 99 },
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
  end

  def width = settings.fetch(:width)
  def height = settings.fetch(:height)
  def mines = settings.fetch(:mines)

  def settings = @settings ||= settings_map.fetch(name)

  private

  def settings_map = self.class.settings_map
end
