# frozen_string_literal: true

require "csv"

class Games::Boards::ImportsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def new
  end

  def create
    if (path = params[:file])
      ImportFlags.(board:, path:)
      redirect_to(root_path)
    else
      redirect_to({ action: :new }, alert: t("flash.not_found", type: "File"))
    end
  end

  class ImportFlags
    include CallMethodBehaviors

    attr_reader :board,
                :path

    def initialize(board:, path:)
      @board = board
      @path = path
    end

    def on_call
      reset_board
      updated_cells = place_flags
      save_flags_placement(updated_cells)
    end

    private

    def reset_board
      board.reset
    end

    def place_flags
      board.cells_at(coordinates_array).each { |cell| cell.flagged = true }
    end

    def save_flags_placement(flagged_cells)
      Cell.for_id(flagged_cells).update_all(flagged: true)
    end

    # :reek:FeatureEnvy
    def coordinates_array
      CSV.foreach(path, headers: true, converters: :integer).map { |row|
        Coordinates[row["x"], row["y"]]
      }
    end
  end
end
