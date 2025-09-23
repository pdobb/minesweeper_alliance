# frozen_string_literal: true

# :reek:InstanceVariableAssumption

# Monkey-patch ActionCable::Connection::ClientSocket to use permessage-deflate.
# See:
# - https://github.com/faye/permessage-deflate-ruby
# - https://sapandiwakar.in/compressing-websocket-actioncable-frames-on-rails-with-permessage-deflate/
class ActionCable::Connection::ClientSocket
  alias old_initialize initialize

  def initialize(...)
    old_initialize(...)
    @driver.add_extension(PermessageDeflate)
  end
end
