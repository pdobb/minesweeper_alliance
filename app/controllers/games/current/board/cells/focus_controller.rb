# frozen_string_literal: true

class Games::Current::Board::Cells::FocusController < ApplicationController
  include Games::Current::Board::Cells::FocusBehaviors

  def create
    cell.focus

    broadcast_update
  end
end
