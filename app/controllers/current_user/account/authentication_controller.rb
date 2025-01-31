# frozen_string_literal: true

class CurrentUser::Account::AuthenticationController < ApplicationController
  # We must use a GET request for this action so that users may authenticate
  # via a bookmarked link.
  def show
    user = User::Authentication.(token: params[:token], context: layout)

    if user
      redirect_to(
        current_user_account_path,
        notice: t("account.authentication.success", name: user.display_name))
    else
      redirect_to(root_path, alert: t("account.authentication.invalid_token"))
    end
  end
end
