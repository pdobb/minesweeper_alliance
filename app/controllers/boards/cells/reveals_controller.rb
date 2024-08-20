# frozen_string_literal: true

class Boards::Cells::RevealsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    @cell.reveal

    redirect_to(game_path(game_id))
  end
end
