# frozen_string_literal: true

# CurrentUser::Account::Username::Edit represents the inline {User#username}
# edit form that shows in the User Account page for current/past signers.
class CurrentUser::Account::Username::Edit
  def initialize(user:)
    @user = user
  end

  def form
    CurrentUser::Account::Username::Form.new(user:)
  end

  private

  attr_reader :user
end
