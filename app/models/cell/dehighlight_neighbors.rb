# frozen_string_literal: true

# Cell::DehighlightNeighbors is a Service Object for coordinating:
# - Calling of {Cell#dehighlight_neighbors} for the passed-in {Cell},
# - and then broadcasting the necessary view-level updates to all of the
#   now-dehighlighted Cells.
class Cell::DehighlightNeighbors
  include CallMethodBehaviors

  def initialize(cell, context:)
    @cell = cell
    @context = context
    @updated_cells = []
  end

  def call
    dehighlight_neighbors
    broadcast if updated_cells?
  end

  private

  attr_reader :cell,
              :context,
              :updated_cells

  def dehighlight_neighbors
    @updated_cells = cell.dehighlight_neighbors
  end

  def broadcast
    BroadcastUpdate.(cell:, updated_cells:, context:)
  end

  def updated_cells? = updated_cells.any?

  # Cell::DehighlightNeighbors::BroadcastUpdate broadcasts the necessary view
  # updates to display the given {Cell}'s base state + the given updated
  # {Cell}s' highlighted state.
  class BroadcastUpdate
    include CallMethodBehaviors

    def initialize(cell:, updated_cells:, context:)
      @cell = cell
      @updated_cells = updated_cells
      @context = context
    end

    def call
      return if updated_cells.none?

      broadcast(turbo_stream_templates)
    end

    private

    attr_reader :cell,
                :updated_cells,
                :context

    def turbo_stream_templates
      [
        originating_cell_turbo_stream_template,
        *neighboring_cells_turbo_stream_templates,
      ].join
    end

    def originating_cell_turbo_stream_template
      TurboStreamTemplate.(cell, context:)
    end

    def neighboring_cells_turbo_stream_templates
      TurboStreamTemplate.wrap(updated_cells, context:).map(&:call)
    end

    def broadcast(content)
      WarRoomChannel.broadcast(content)
    end

    # Cell::DehighlightNeighbors::BroadcastUpdate::TurboStreamTemplate builds a
    # <turbo_stream> template with a single `target`, to which the determined
    # `css` styles will be applied.
    class TurboStreamTemplate
      include WrapMethodBehaviors
      include CallMethodBehaviors

      def initialize(cell, context:)
        @cell = cell
        @context = context
      end

      def call
        helpers.replace_css(target:, css:)
      end

      private

      attr_reader :cell,
                  :context

      def helpers = context.helpers

      def target = helpers.dom_id(cell)
      def css = cell_view_model.css
      def cell_view_model = Games::Current::Board::Cell.new(cell)
    end
  end
end
