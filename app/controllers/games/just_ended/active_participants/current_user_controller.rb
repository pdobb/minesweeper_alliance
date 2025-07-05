# frozen_string_literal: true

class Games::JustEnded::ActiveParticipants::CurrentUserController <
        ApplicationController
  before_action :require_game

  def show
    @show =
      Games::JustEnded::ActiveParticipants::CurrentUser::Show.new(
        game:, user: current_user,
      )
  end

  def edit
    @edit =
      Games::JustEnded::ActiveParticipants::CurrentUser::Edit.new(
        game:, user: current_user,
      )
  end

  def update # rubocop:disable Metrics/AbcSize
    if User::Update.(current_user, attributes: update_params)
      User::Update::Broadcast.(user: current_user, turbo_stream:)

      respond_to do |format|
        format.html do
          redirect_to(
            { action: :show },
            notice:
              t("flash.successful_update_to",
                type: "username",
                to: current_user.display_name),
          )
        end
        format.turbo_stream {
          @update =
            Games::JustEnded::ActiveParticipants::CurrentUser::Update.new(
              game:, user: current_user,
            )
        }
      end
    else
      edit
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  attr_accessor :game

  def require_game
    self.game = Game.find(params[:game_id])
  end

  def update_params
    params.expect(user: %i[username])
  end
end
