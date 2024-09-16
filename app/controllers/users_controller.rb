# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
  end

  def update
    current_user = layout.current_user
    current_user.attributes = update_params

    if current_user.save
      redirect_to(
        root_path,
        notice:
          t(
            "flash.successful_update_to",
            type: "username",
            to: current_user.display_name))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def update_params
    params.require(:user).permit(:username)
  end
end
