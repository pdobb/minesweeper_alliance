# frozen_string_literal: true

# ApplicationCable::Connection is the base connection for Turbo::Streams.
class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user_token

  def connect
    self.current_user_token = cookies.signed[:user_token]
  end
end
