# frozen_string_literal: true

class Games::UsersController < ApplicationController
  before_action :require_game, only: %i[edit update]

  def edit
    @view = Games::Users::Edit.new(game: @game, user: current_user)
  end

  # :reek:TooManyStatements

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    current_user.attributes = update_params

    if current_user.save
      respond_to do |format|
        format.html do
          redirect_to(
            root_path,
            notice:
              t(
                "flash.successful_update_to",
                type: "username",
                to: current_user.display_name))
        end
        format.turbo_stream {
          @view = Games::Users::Update.new(game: @game, user: current_user)
        }
      end
    else
      edit
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def require_game
    @game = Game.find(params[:game_id])
  end

  def update_params
    params.require(:user).permit(:username)
  end

  def current_user = @current_user ||= layout.current_user
end
