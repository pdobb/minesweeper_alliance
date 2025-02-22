# frozen_string_literal: true

class CurrentUser::AccountController < ApplicationController
  before_action :require_participant

  after_action RecordVisit

  def show
    @view = CurrentUser::Account::Show.new(user: current_user)
  end

  def destroy
    FleetTracker.expire!(current_user.token)
    ActionCable.server.remote_connections.where(current_user:).
      disconnect(reconnect: false)

    current_user_will_change
    clear_all_cookies
    reset_session

    redirect_to(root_path)
  end

  private

  def clear_all_cookies
    cookies.pluck(0).each { cookies.delete(it) }
  end

  def require_participant
    redirect_to(root_path) unless current_user.participant?
  end
end
