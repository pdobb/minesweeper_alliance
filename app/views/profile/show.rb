# frozen_string_literal: true

# Profile::Show
class Profile::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name

  def reset_profile_url = Router.profile_path

  private

  attr_reader :user
end
