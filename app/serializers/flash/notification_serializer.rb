# frozen_string_literal: true

# Flash::NotificationSerializer provides an ActiveJob serialization interface
# for# {Application::Flash::Notification}s.
class Flash::NotificationSerializer < ActiveJob::Serializers::ObjectSerializer
  # :reek:FeatureEnvy

  def serialize(notification)
    super(type: notification.type, content: notification.content)
  end

  # Converts serialized value into a proper object.
  def deserialize(hash)
    klass.new(**hash.slice(:type, :content))
  end

  private

  def klass
    Application::Flash::Notification
  end
end
