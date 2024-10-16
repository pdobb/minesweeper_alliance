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
      broadcast_update(game: @game)

      respond_to do |format|
        format.html do
          redirect_to(
            root_path,
            notice:
              t("flash.successful_update_to",
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

  def broadcast_update(game:)
    Turbo::StreamsChannel.broadcast_update_to(
      game,
      :duty_roster,
      target: helpers.dom_id(current_user),
      partial: "games/users/duty_roster_listing",
      locals: {
        listing: Games::Users::DutyRoster::Listing.new(current_user, game:),
      })
  end
end
