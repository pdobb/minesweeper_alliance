# frozen_string_literal: true

class Cells::RevealsController < ApplicationController
  include CellActionBehaviors

  def create
    @cell.reveal

    redirect_to(root_path)
  end
end
