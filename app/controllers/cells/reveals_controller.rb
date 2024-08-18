# frozen_string_literal: true

class Cells::RevealsController < ApplicationController
  before_action :require_cell

  def create
    @cell.reveal

    redirect_to(root_path)
  end

  private

  def require_cell
    @cell = Cell.find(params[:cell_id])
  end
end
