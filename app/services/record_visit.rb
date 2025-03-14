# frozen_string_literal: true

# RecordVisit coordinates with {Visit} to record a count of requests/visits to
# the named resource for the passed-in `controller`.
class RecordVisit
  # Controller callback hook for `after_action` calls.
  #
  # @example
  #   after_action RecordVisit, only: :show
  def self.after(controller)
    return unless record?(current_user: controller.current_user)

    new(controller:).call
  end

  def self.record?(current_user:)
    current_user.participant? && !User::Current.dev?(current_user)
  end
  private_class_method :record?

  def initialize(controller:)
    @controller = controller
  end

  def call
    Visit.transaction do
      find_or_create_record
      increment_count
    end
  end

  private

  attr_reader :controller
  attr_accessor :record

  def request = controller.request
  def path = request.fullpath

  def find_or_create_record
    self.record = Visit.find_or_create_by!(path:)
  end

  def increment_count
    record.increment!(:count, touch: true)
  end
end
