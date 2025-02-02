# frozen_string_literal: true

class Games::New::CustomController < ApplicationController
  def new
    @view = Games::New::Custom::New.new
  end

  # :reek:TooManyStatements
  def create # rubocop:disable Metrics/MethodLength
    settings = Board::Settings.custom(**settings_params.to_h.symbolize_keys)

    if settings.valid?
      context = GamesController::CurrentGameContext.new(self)
      Game::Current.(settings:, context:) {
        layout.store_http_cookie(
          Games::New::Custom::Form::COOKIE,
          value: settings.to_json)
      }

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
