# frozen_string_literal: true

# Version: 20250130002840
class AddAuthenticationTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    enable_extension("uuid-ossp")

    add_column(
      :users,
      :authentication_token,
      :uuid,
      null: false,
      default: -> { "uuid_generate_v4()" })
    add_index(:users, :authentication_token, unique: true)
  end
end
