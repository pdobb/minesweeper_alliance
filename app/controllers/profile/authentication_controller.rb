# frozen_string_literal: true

class Profile::AuthenticationController < ApplicationController
  # We must use a GET request for this action so that users may authenticate
  # via a bookmarked link.
  def show
    user = User::Authentication.(token: params[:token], context: layout)

    if user
      redirect_to(
        profile_path,
        notice: t("profile.authentication.success", name: user.display_name))
    else
      redirect_to(root_path, alert: t("profile.authentication.invalid_token"))
    end
  end
end
