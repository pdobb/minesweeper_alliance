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
    User::Current.call(context: Context.new(self))
  end

  # ApplicationCable::Connection::Context is a proxy for the private
  # ApplicationCable::Connection#cookies method.
  class Context
    def initialize(context) = @context = context
    def cookies = @context.__send__(:cookies)
  end
end
