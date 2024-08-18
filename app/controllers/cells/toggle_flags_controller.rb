# frozen_string_literal: true

class Cells::ToggleFlagsController < ApplicationController
  include CellActionBehaviors

  def create
    @cell.toggle_flag

    redirect_to(root_path)
  end
end
