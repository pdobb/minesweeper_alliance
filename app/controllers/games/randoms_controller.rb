# frozen_string_literal: true

class Games::RandomsController < ApplicationController
  include Games::CreateBehaviors

  def create
    find_or_create_game(settings: Board::Settings.random)
    redirect_to(root_path)
  end
end
