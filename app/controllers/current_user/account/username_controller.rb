# frozen_string_literal: true

class CurrentUser::Account::UsernameController < ApplicationController
  def show
    @show = CurrentUser::Account::Username::Show.new(user: current_user)
  end

  def edit
    @edit = CurrentUser::Account::Username::Edit.new(user: current_user)
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
          username = CurrentUser::Account::Username.new(user: current_user)
          render(
            turbo_stream:
              turbo_stream.update(
                username.turbo_frame_name,
                partial: "current_user/account/username",
                locals: { username: },
              ),
          )
        }
      end
    else
      edit
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def update_params
    params.expect(user: %i[username])
  end
end
