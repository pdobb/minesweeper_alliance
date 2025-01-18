# frozen_string_literal: true

class Games::New::CustomController < ApplicationController
  include Games::New::Behaviors

  def new
    @view = Games::New::Custom::New.new
  end

  def create
    settings = Board::Settings.custom(**settings_params.to_h.symbolize_keys)

    if settings.valid?
      find_or_create_current_game(settings:)
      redirect_to(root_path)
    else
      @view = Games::New::Custom::New.new(settings:)
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def settings_params
    params.expect(
      board_settings: %i[
        width
        height
        mines
      ])
  end
end
