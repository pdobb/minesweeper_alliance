# frozen_string_literal: true

# RecordInteraction coordinates with {Interaction} to record a count of
# interactions with the named element, link, resource ...
class RecordInteraction
  def self.call(...) = new(...).call

  def self.record?(current_user:) = User::Type.non_dev?(current_user)

  def initialize(name:)
    @name = name
  end

  def call
    Interaction.transaction do
      find_or_create_record
      increment_count
    end
  end

  private

  attr_reader :name
  attr_accessor :record

  def find_or_create_record
    self.record = Interaction.find_or_create_by!(name:)
  end

  def increment_count
    record.increment!(:count, touch: true)
  end
end
