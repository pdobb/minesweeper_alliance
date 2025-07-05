# frozen_string_literal: true

class Games::New::CustomController < ApplicationController
  after_action RecordVisit

  def new
    @new = Games::New::Custom::New.new
  end

  def create # rubocop:disable Metrics/AbcSize
    settings = Board::Settings.custom(**settings_params.to_h.symbolize_keys)

    if settings.valid?
      context = GamesController::CurrentGameContext.new(self)
      Game::Current.(settings:, context:) {
        layout.store_http_cookie(
          Games::New::Custom::Form::COOKIE,
          value: settings.to_json,
        )
      }

      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.turbo_stream do
          render(turbo_stream: turbo_stream.action(:redirect, root_path))
        end
      end
    else
      @new = Games::New::Custom::New.new(settings:)
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
      ],
    )
  end
end
