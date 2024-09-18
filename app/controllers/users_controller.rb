# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
  end

  # :reek:TooManyStatements

  def update # rubocop:disable Metrics/MethodLength
    current_user = layout.current_user

    current_user.attributes = update_params
    if current_user.save
      notice =
        t("flash.successful_update_to", # rubocop:disable Layout/FirstMethodArgumentLineBreak
          type: "username",
          to: current_user.display_name)

      respond_to do |format|
        format.html { redirect_to(root_path, notice:) }
        format.turbo_stream
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
