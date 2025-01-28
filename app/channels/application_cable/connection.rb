# frozen_string_literal: true

# ApplicationCable::Connection is the base connection for Turbo::Streams.
class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user

  def connect
    self.current_user = find_current_user

    logger.add_tags("ActionCable")
    logger.add_tags(current_user.identifier) if Rails.env.development?
  end

  private

  def find_current_user
    User.for_token(cookies.signed[CurrentUser::COOKIE]).take
  end
end
