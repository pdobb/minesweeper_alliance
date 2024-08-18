# frozen_string_literal: true

class Cells::ToggleFlagsController < ApplicationController
  before_action :require_cell

  def create
    @cell.toggle_flag

    redirect_to(root_path)
  end

  private

  def require_cell
    @cell = Cell.find(params[:cell_id])
  end
end
