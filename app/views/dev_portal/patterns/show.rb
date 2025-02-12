# frozen_string_literal: true

# DevPortal::Patterns::Show
class DevPortal::Patterns::Show
  def initialize(pattern)
    @pattern = pattern
  end

  def name = pattern.name

  def rows
    grid.map { |row| Cell.wrap(row) }
  end

  def edit_pattern_url
    Router.edit_dev_portal_pattern_path(pattern)
  end

  def destroy_pattern_url
    Router.dev_portal_pattern_path(pattern)
  end

  def toggle_flag_url
    Router.dev_portal_pattern_toggle_flag_path(pattern)
  end

  def pattern_reset_url
    Router.dev_portal_pattern_resets_path(pattern)
  end

  def pattern_export_url
    Router.dev_portal_pattern_exports_path(pattern)
  end

  def pattern_import_url
    Router.new_dev_portal_pattern_import_path(pattern)
  end

  def dimensions = pattern.dimensions

  def flag_density_percent
    flag_density * 100.0
  end

  def flag_density_css
    if Board::Settings::RANGES.fetch(:mine_density).exclude?(flag_density)
      "text-red-600"
    end
  end

  private

  attr_reader :pattern

  def grid = pattern.grid
  def flag_density = pattern.flag_density

  # DevPortal::Patterns::Show::Cell is a View Model for displaying virtual
  # {Pattern} "Cells".
  class Cell
    include WrapMethodBehaviors

    def initialize(cell)
      @cell = cell
    end

    def id = cell.id
    def flagged? = cell.flagged?
    def coordinates = cell.coordinates

    def to_s
      if flagged?
        Emoji.flag
      else
        ""
      end
    end

    private

    attr_reader :cell
  end
end
