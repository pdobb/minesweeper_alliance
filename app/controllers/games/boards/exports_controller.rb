# frozen_string_literal: true

class Games::Boards::ExportsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    path = Board::Export.(board:)
    redirect_to(
      root_path,
      notice: "Exported to: #{path.relative_path_from(Rails.root)}")
  end
end
