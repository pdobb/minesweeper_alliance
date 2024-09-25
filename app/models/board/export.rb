# frozen_string_literal: true

require "csv"

# Board::Export is a Service Object for exporting {Board} patterns.
class Board::Export
  include CallMethodBehaviors

  attr_reader :board,
              :path

  def initialize(board:)
    @board = board

    @path = Rails.root.join("tmp/patterns/#{filename}.csv")
    FileUtils.mkdir_p(@path.dirname)
  end

  def on_call
    csv_string = CSV.generate_lines(coordinates_with_header)

    path.open("w") do |file|
      file.write(csv_string)
      path
    end
  end

  private

  def game_type = board.settings.name.downcase
  def dimensions = board.dimensions

  def cells = board.cells

  def filename(time: Time.current)
    timestamp = I18n.l(time, format: :file)
    "#{timestamp}-#{dimensions}"
  end

  def coordinates_with_header
    coordinates =
      cells.select(&:flagged?).map! { |cell| cell.coordinates.to_a }

    coordinates.prepend(%w[x y])
  end
end
