# frozen_string_literal: true

# Cell::ToggleFlag is a Service Object for coordinating:
# - Calling of {Cell#toggle_flag} for the passed-in {Cell},
# - and then broadcasting the necessary CSS/content updates to the associated
#   Cell object in the view.
class Cell::ToggleFlag
  include CallMethodBehaviors

  def initialize(cell, context:)
    @cell = cell
    @context = context
  end

  def call
    cell.transaction do
      toggle_flag
      create_transaction_record
    end

    broadcast
  end

  private

  attr_reader :cell,
              :context

  def toggle_flag
    cell.toggle_flag
  end

  def create_transaction_record
    transaction_class.create_between(user: current_user, cell:)
  end

  def transaction_class
    cell.flagged? ? CellFlagTransaction : CellUnflagTransaction
  end

  def broadcast
    BroadcastUpdate.(cell:, context:)
  end

  def current_user = context.current_user
  def cell_view_model = Games::Current::Board::Cell.new(cell)

  # Cell::ToggleFlag::BroadcastUpdate broadcasts the necessary view updates
  # needed to toggle display of the given {Cell}'s flagged state.
  class BroadcastUpdate
    include CallMethodBehaviors

    def initialize(cell:, context:)
      @cell = cell
      @context = context
    end

    def call
      broadcast(turbo_stream_template)
    end

    private

    attr_reader :cell,
                :context

    def helpers = context.helpers

    def turbo_stream_template
      context.render_to_string(
        partial: "games/current/board/cell",
        locals: {
          cell: Games::Current::Board::Cell.new(cell),
        })
    end

    def broadcast(content)
      WarRoomChannel.broadcast_replace(target: cell, html: content)
    end
  end
end
