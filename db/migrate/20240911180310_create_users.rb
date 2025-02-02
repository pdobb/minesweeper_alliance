# frozen_string_literal: true

# Version: 20240911180310
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    enable_extension("uuid-ossp")

    create_table(:users, id: :uuid) do |t|
      t.string(:username, index: true)
      t.string(:time_zone)
      t.string(:user_agent)
      t.uuid(
        :authentication_token,
        null: false,
        default: -> { "uuid_generate_v4()" })

      t.timestamps
    end

    add_index(:users, :authentication_token, unique: true)
  end
end
