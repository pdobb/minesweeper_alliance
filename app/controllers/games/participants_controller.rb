# frozen_string_literal: true

class Games::ParticipantsController < ApplicationController
  before_action :require_game, only: %i[edit update]

  def edit
    @view = Games::Participants::Edit.new(game: @game, user: current_user)
  end

  # :reek:TooManyStatements

  def update # rubocop:disable Metrics/MethodLength
    if UpdateUser.(current_user, attributes: update_params)
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
          @view =
            Games::Participants::Update.new(game: @game, user: current_user)
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

  # :reek:FeatureEnvy
  def broadcast_update(game:)
    duty_roster_listing =
      Games::Participants::DutyRoster::Listing.new(current_user, game:)

    Turbo::StreamsChannel.broadcast_update_to(
      Games::Participants::DutyRoster.turbo_stream_name(game),
      target: duty_roster_listing.dom_id,
      html: duty_roster_listing.name)
  end

  # UpdateUser
  class UpdateUser
    include CallMethodBehaviors

    def initialize(user, attributes:)
      @user = user
      @attributes = attributes
    end

    def call
      user.attributes = attributes
      user.user_update_transactions.build(change_set:) if username_changed?
      user.save
    end

    private

    attr_reader :user,
                :attributes

    def change_set
      { username: username_change_set }
    end

    def username_change_set
      { old: old_username, new: new_username }
    end

    def username_changed? = user.username_changed?
    def old_username = user.username_was
    def new_username = user.username
  end
end
