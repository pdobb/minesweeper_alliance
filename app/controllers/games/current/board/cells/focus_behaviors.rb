# frozen_string_literal: true

# Games::Current::Board::Cells::FocusBehaviors
module Games::Current::Board::Cells::FocusBehaviors
  extend ActiveSupport::Concern

  included do
    skip_before_action :set_time_zone
  end

  private

  def cell
    @cell ||= Cell.find(params[:cell_id])
  end

  def broadcast_update
    WarRoomChannel.broadcast(
      Cell::TurboStream::Morph.(cell, turbo_stream:))
  end
end
