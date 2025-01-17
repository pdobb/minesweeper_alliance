# frozen_string_literal: true

# Version: 20250117181518
class AddUserAgentToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column(:users, :user_agent, :string)
  end
end
