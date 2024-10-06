# frozen_string_literal: true

class CurrentUser::TimeZoneUpdatesController < ApplicationController
  def create
    time_zone_params[:time_zone].tap do |time_zone|
      layout.current_user.update!(time_zone:)
      layout.store_cookie(:time_zone, value: time_zone)
    end

    head(:ok)
  end

  private

  def time_zone_params
    params.require(:time_zone_update).permit(:time_zone)
  end
end
