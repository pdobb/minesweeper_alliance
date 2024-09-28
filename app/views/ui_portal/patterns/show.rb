# frozen_string_literal: true

# UIPortal::Patterns::Show
class UIPortal::Patterns::Show
  def initialize(pattern)
    @pattern = pattern
  end

  def name = pattern.name

  def rows
    grid.map { |row| Cell.wrap(row) }
  end

  def edit_pattern_url(router = RailsRouter.instance)
    router.edit_ui_portal_pattern_path(pattern)
  end

  def destroy_pattern_url(router = RailsRouter.instance)
    router.ui_portal_pattern_path(pattern)
  end

  def toggle_flag_url(router = RailsRouter.instance)
    router.ui_portal_pattern_toggle_flag_path(pattern)
  end

  def pattern_reset_url(router = RailsRouter.instance)
    router.ui_portal_pattern_resets_path(pattern)
  end

  def pattern_export_url(router = RailsRouter.instance)
    router.ui_portal_pattern_exports_path(pattern)
  end

  def pattern_import_url(router = RailsRouter.instance)
    router.new_ui_portal_pattern_import_path(pattern)
  end

  def dimensions = pattern.dimensions

  def flag_density_percent
    flag_density * 100.0
  end

  def flag_density_css_class
    if Board::Settings::RANGES.fetch(:mine_density).exclude?(flag_density)
      "text-red-600"
    end
  end

  private

  attr_reader :pattern

  def grid = pattern.grid

  def flag_density = pattern.flag_density

  # UIPortal::Patterns::Show::Cell is a view model for displaying virtual
  # {Pattern} "Cells".
  class Cell
    include WrapMethodBehaviors

    def initialize(model)
      @model = model
    end

    def id = to_model.id
    def flagged? = to_model.flagged?
    def coordinates = to_model.coordinates

    def to_s
      if flagged?
        Icon.flag
      else
        ""
      end
    end

    private

    def to_model = @model
  end
end
