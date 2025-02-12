# frozen_string_literal: true

class Games::Current::Board::Cells::UnfocusController < ApplicationController
  include Games::Current::Board::Cells::FocusBehaviors

  def create
    cell.unfocus

    broadcast_update
  end
end
