# frozen_string_literal: true

# CurrentUser::Nav represents the right side of the nav bar, where the Current
# {User}'s username / account link is displayed--for participants only, not
# {Guest}s.
class CurrentUser::Nav
  def initialize(user:)
    @user = user
  end

  def turbo_update_target = "currentUserNav"

  def participant? = user.active_participant?

  def account_url
    Router.current_user_account_path
  end

  def turbo_update_id = View.dom_id(user)
  def display_name = user.display_name

  private

  attr_reader :user
end
