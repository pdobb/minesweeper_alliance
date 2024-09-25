# frozen_string_literal: true

# Games::Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers
# that need to operate on {Board}s and their associated {Cell}s.
module Games::Boards::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  include Games::Boards::ActionBehaviors

  # Games::Boards::Cells::ActionBehaviors::Error represents any StandardError
  # related to Game / Board / Cell Actions processing.
  Error = Class.new(StandardError)

  private

  def cell
    @cell ||= begin
      cell_id = params[:cell_id]
      board.cells.to_a.detect { |cell| cell.to_param == cell_id }.tap { |cell|
        unless cell
          raise(Error, "couldn't find Cell with id #{cell_id.inspect}")
        end
      }
    end
  end

  def current_context
    CurrentContext.new(self)
  end

  # Games::Boards::Cells::ActionBehaviors::CurrentContext
  class CurrentContext
    def initialize(context)
      @context = context
    end

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = layout.current_user
    def layout = context.layout

    private

    attr_reader :context
  end
end
