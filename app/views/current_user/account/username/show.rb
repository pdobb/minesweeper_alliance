# frozen_string_literal: true

# CurrentUser::Account::Username::Show represents the {User#username} link that
# triggers / swaps with the inline edit form in the User Account page for
# current/past signers.
class CurrentUser::Account::Username::Show
  def initialize(user:)
    @user = user
  end

  def username
    CurrentUser::Account::Username.new(user:)
  end

  private

  attr_reader :user
end
