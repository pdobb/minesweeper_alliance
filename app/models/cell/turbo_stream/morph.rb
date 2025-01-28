# frozen_string_literal: true

# Cell::TurboStream::Morph ...
#
# @example Call
#   Cell::TurboStream::Morph.(cell, turbo_stream:)
#
# @example Wrap and Call on a collection
#   Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:)
class Cell::TurboStream::Morph
  REMOVE_SOURCE_REGEX = / data-source=".*"/

  include WrapAndCallMethodBehaviors

  def self.remove_source!(html)
    html.tap { it.remove!(REMOVE_SOURCE_REGEX) }
  end

  def initialize(cell, turbo_stream:)
    @cell = cell
    @turbo_stream = turbo_stream
  end

  def call
    turbo_stream.sourced_replace(
      cell_view_model.dom_id,
      partial: cell_view_model,
      method: :morph)
  end

  private

  attr_reader :cell,
              :turbo_stream

  def target = cell_view_model.dom_id

  def cell_view_model
    @cell_view_model ||= Games::Current::Board::Cell.new(cell)
  end
end
