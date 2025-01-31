# frozen_string_literal: true

class CurrentUser::AccountController < ApplicationController
  before_action :require_active_participant

  def show
    @view = CurrentUser::Account::Show.new(user: current_user)
  end

  def destroy
    clear_all_cookies
    redirect_to(root_path)
  end

  private

  def clear_all_cookies
    cookies.pluck(0).each { cookies.delete(it) }
  end

  def require_active_participant
    redirect_to(root_path) unless current_user.active_participant?
  end
end
