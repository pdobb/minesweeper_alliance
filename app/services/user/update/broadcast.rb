# frozen_string_literal: true

# User::Update::Broadcast handles Turbo Stream Broadcast of {User} updates via
# the "global" channel. It aims to be efficient by sending just a single
# broadcast event--even given multiple `update`s to perform.
class User::Update::Broadcast
  STREAM_NAME = Application::Layout.turbo_stream_name

  def self.call(...) = new(...).call

  def initialize(user:, turbo_stream:)
    @user = user
    @turbo_stream = turbo_stream
  end

  def call
    broadcast {
      [
        display_name_updates,
        username_updates,
      ]
    }
  end

  private

  attr_reader :user,
              :turbo_stream

  def broadcast
    ActionCable.server.broadcast(STREAM_NAME, yield.join)
  end

  def display_name_updates
    turbo_stream.update_all(
      ".#{View.dom_id(user, :display_name)}",
      html: user.display_name)
  end

  def username_updates
    turbo_stream.update_all(
      ".#{View.dom_id(user, :username)}",
      html: user.username)
  end
end
