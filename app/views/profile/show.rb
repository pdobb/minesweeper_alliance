# frozen_string_literal: true

# Profile::Show
class Profile::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name

  private

  attr_reader :user
end
