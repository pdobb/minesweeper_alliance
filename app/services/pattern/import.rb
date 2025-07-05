# frozen_string_literal: true

require "csv"

# Pattern::Import is a Service Object for importing {Pattern}s from CSV.
class Pattern::Import
  attr_reader :path

  def self.call(...) = new(...).call

  def initialize(path:)
    @path = path
    @meta_data = []
  end

  # :reek:FeatureEnvy

  def call
    result = ProcessCSV.(path:, header:)

    attributes = result.fetch(:attributes)
    coordinates_set = result.fetch(:coordinates_set)

    Pattern.create(
      name: attributes.fetch(:name),
      settings:
        Pattern::Settings.new(
          width: attributes.fetch(:width),
          height: attributes.fetch(:height),
        ),
      coordinates_set:,
    )
  end

  private

  def header
    %w[x y]
  end

  # Pattern::Import::ProcessCSV is a Service Object for handling meta data and
  # CSV data processing for the given {#path} based on the given (expected)
  # {#header}.
  class ProcessCSV
    attr_reader :path,
                :header

    def self.call(...) = new(...).call

    def initialize(path:, header:)
      @path = path
      @header = header
    end

    def call
      meta_data, csv_data = split_meta_data_from_csv_data

      attributes = build_attributes(meta_data)
      coordinates_set = build_coordinates_set(csv_data)

      { attributes:, coordinates_set: }
    end

    private

    # :reek:FeatureEnvy
    def split_meta_data_from_csv_data(csv_data: path.read)
      scanner = StringScanner.new(csv_data)
      meta_data =
        Array.new(Pattern::Export::META_DATA_LINES_COUNT) {
          scanner.scan_until(/\r?\n|\r/).to_s.chomp
        }

      raw_data_body = scanner.rest

      [meta_data, raw_data_body]
    end

    # :reek:FeatureEnvy
    def build_attributes(meta_data)
      hash = parse_meta_data(meta_data)

      name = hash[Pattern::Export::NAME_KEY]
      width, height =
        hash[Pattern::Export::DIMENSIONS_KEY].split("x").map(&:to_i)

      { name:, width:, height: }
    end

    def parse_meta_data(meta_data)
      meta_data.each_with_object({}) { |string, acc|
        key, value = string.split(": ")
        acc[key] = value
      }
    end

    # :reek:FeatureEnvy
    def build_coordinates_set(csv_data)
      csv_table = parse_csv(csv_data)

      csv_table.map { |csv_row|
        Coordinates[csv_row["x"], csv_row["y"]]
      }
    end

    def parse_csv(csv_data)
      CSV.parse(csv_data, headers: true, converters: :integer)
    end
  end
end
