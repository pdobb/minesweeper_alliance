# frozen_string_literal: true

# CurrentUser::Nav represents the right side of the nav bar, where the Current
# {User}'s username / account link is displayed--for participants only, not
# {Guest}s.
class CurrentUser::Nav
  def initialize(user:)
    @user = user
  end

  def turbo_target = "currentUserNav"

  def participant? = user.participant?
  def signer? = user.signer?

  def account_url
    Router.current_user_account_path
  end

  def updateable_display_name = View.updateable_display_name(user:)

  private

  attr_reader :user
end
