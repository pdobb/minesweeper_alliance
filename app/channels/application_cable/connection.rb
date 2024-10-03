# frozen_string_literal: true

# ApplicationCable::Connection is the base connection for Turbo::Streams.
class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user_token

  def connect
    self.current_user_token = App.debug? ? username : user_token
  end

  private

  def username = User.find(user_token).username || user_token
  def user_token = cookies[:user_token]
end
