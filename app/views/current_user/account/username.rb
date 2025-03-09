# frozen_string_literal: true

# CurrentUser::Account::Username
class CurrentUser::Account::Username
  def self.turbo_frame_name(user:) = [user, :username]

  def initialize(user:)
    @user = user
  end

  def editable? = user.ever_signed?

  def turbo_frame_name = self.class.turbo_frame_name(user:)

  def link_content
    View.updateable_display_name(user:)
  end

  def edit_url
    Router.edit_current_user_account_username_path
  end

  def updateable_display_name = View.updateable_display_name(user:)

  private

  attr_reader :user
end
