# frozen_string_literal: true

# CurrentUser::Account::Show
class CurrentUser::Account::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name

  def personnel_file_url(current_user:) = Router.user_path(current_user)

  def username
    CurrentUser::Account::Username.new(user:)
  end

  def time_zone_form
    Users::TimeZone::Form.new(user:)
  end

  def authentication_url
    Router.current_user_account_authentication_path(token:)
  end

  def reset_account_url = Router.current_user_account_path

  private

  attr_reader :user

  def token = user.authentication_token
end
