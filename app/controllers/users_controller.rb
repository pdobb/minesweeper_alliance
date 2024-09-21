# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    if (user = User.for_id(params[:id]).take)
      @view = Users::Show.new(user:, context: layout)
    else
      redirect_to(root_path, alert: t("flash.not_found", type: "User"))
    end
  end

  def edit
  end

  # :reek:TooManyStatements
  # :reek:NilCheck

  def update # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    current_user = layout.current_user

    current_user.attributes = update_params
    if current_user.save
      notice =
        t("flash.successful_update_to", # rubocop:disable Layout/FirstMethodArgumentLineBreak
          type: "username",
          to: current_user.display_name)

      respond_to do |format|
        format.html { redirect_to(root_path, notice:) }
        format.turbo_stream {
          @signer_status_has_changed =
            current_user.username_previously_was.nil? ||
              current_user.username.nil?
        }
      end
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def update_params
    params.require(:user).permit(:username)
  end
end
