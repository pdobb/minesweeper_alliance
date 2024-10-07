# frozen_string_literal: true

class CurrentUser::TimeZoneUpdatesController < ApplicationController
  def create
    layout.current_user.update!(time_zone: new_time_zone)

    cookies.permanent[:time_zone] = {
      value: new_time_zone,
      secure: App.production?,
    }

    render(turbo_stream: turbo_stream.refresh)
  end

  private

  def time_zone_params
    params.require(:time_zone_update).permit(:time_zone)
  end

  def new_time_zone
    @new_time_zone ||= begin
      name = time_zone_params[:time_zone]
      ActiveSupport::TimeZone::MAPPING.key(name) || name
    end
  end
end
