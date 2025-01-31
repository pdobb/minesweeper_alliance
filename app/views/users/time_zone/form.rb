# frozen_string_literal: true

# Users::TimeZone::Form wraps the drop-down/select form that updates
# {User#time_zone}.
class Users::TimeZone::Form
  def initialize(user:)
    @user = user
  end

  def to_model = UserWrapper.new(user)

  def post_url
    Router.current_user_time_zone_update_path
  end

  def priority_zones = ActiveSupport::TimeZone.us_zones

  private

  attr_reader :user

  # Users::TimeZone::Form::UserWrapper acts as an ActiveModel for representing
  # a {User} form.
  class UserWrapper
    def initialize(user)
      @user = user
    end

    def model_name = @user.model_name

    def time_zone
      @user.time_zone || Time.zone.name
    end
  end
end
