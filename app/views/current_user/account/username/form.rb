# frozen_string_literal: true

# CurrentUser::Account::Username::Form represents a simple form for editing the
# Current User's {User#username}.
class CurrentUser::Account::Username::Form
  def initialize(user:)
    @user = user
  end

  def turbo_frame_name
    CurrentUser::Account::Username.turbo_frame_name(user:)
  end

  def to_model = user

  def update_url = Router.current_user_account_username_path
  def cancel_url = Router.current_user_account_username_path

  private

  attr_reader :user
end
