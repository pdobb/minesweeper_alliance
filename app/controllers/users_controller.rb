# frozen_string_literal: true

class UsersController < ApplicationController
  include AllowBrowserBehaviors

  def show
    if (user = User.for_id(params[:id]).take)
      @view = Users::Show.new(user:)
    else
      redirect_to(root_path, alert: t("flash.not_found", type: "User"))
    end
  end
end
