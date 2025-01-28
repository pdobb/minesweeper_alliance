# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_time_zone

  helper_method :layout,
                :current_user

  def layout
    @layout ||= Application::Layout.new(context: self)
  end

  def current_user
    @current_user ||= User::Current.(context: layout)
  end

  private

  def set_time_zone
    if (time_zone = current_user.time_zone).present?
      Time.zone = time_zone
    end
  rescue ArgumentError
    # We use JavaScript to discover the user's current Time Zone. However,
    # sometimes this resolves to `Etc/Unknown`, perhaps from e.g. bots/crawlers
    # in a headless environment. Either way, when Rails is given this it raises:
    # `ArgumentError: Invalid Timezone: Etc/Unknown`. We're fine to just swallow
    # this error type and move on with the default Time zone.
  end
end
