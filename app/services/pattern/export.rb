# frozen_string_literal: true

require "csv"

# Pattern::Export is a Service Object for exporting {Pattern}s to CSV.
class Pattern::Export
  NAME_KEY = "Name"
  DIMENSIONS_KEY = "Dimensions"
  META_DATA_LINES_COUNT = 2

  attr_reader :pattern,
              :path

  def self.call(...) = new(...).call

  def initialize(pattern:)
    @pattern = pattern

    @path = Rails.root.join("tmp/patterns/#{filename}.csv")
    FileUtils.mkdir_p(@path.dirname)
  end

  def call
    csv_string = generate_csv

    path.open("w") do |file|
      file.write(csv_string)
      path
    end
  end

  private

  def generate_csv
    CSV.generate(headers: true) do |csv|
      # Meta Data
      csv << ["#{NAME_KEY}: #{name}"]
      csv << ["#{DIMENSIONS_KEY}: #{dimensions}"]

      csv << header

      generate_csv_body(csv)
    end
  end

  def generate_csv_body(csv)
    body.each { |row| csv << row }
  end

  def filename = name.downcase
  def name = pattern.name
  def dimensions = pattern.dimensions

  def cells = pattern.cells

  def header
    %w[x y]
  end

  def body
    pattern.coordinates_set.map(&:to_a)
  end
end
