# frozen_string_literal: true

# TurboStreamActions collects Turbo Stream actions intended for response,
# broadcast, or both. Collections are {FlatArray}s.
class TurboStreamActions
  # TurboStreamActions::Response collects response actions into a {FlatArray}.
  Response = Class.new(FlatArray)

  # TurboStreamActions::Broadcast collects broadcast actions into a {FlatArray}.
  Broadcast = Class.new(FlatArray)

  def initialize
    @hash = {
      response: Response.new,
      broadcast: Broadcast.new,
    }
  end

  def <<(value)
    response << value
    broadcast << value
  end

  def response = hash.fetch(:response)
  def broadcast = hash.fetch(:broadcast)

  def size
    (response | broadcast).size
  end

  private

  attr_reader :hash

  concerning :ObjectInspection do # rubocop:disable Metrics/BlockLength
    include ObjectInspectionBehaviors

    private

    def inspect_identification = self.class.name

    def inspect_info
      "Size: #{size} "\
        "(#{describe_response_counts} | #{describe_broadcast_counts})"
    end

    def describe_response_counts(separator: ", ")
      counts = [
        if unique_responses_count.positive? # rubocop:disable Style/IfUnlessModifier
          "#{unique_responses_count} uniq"
        end,
        if non_unique_responses_count.positive?
          "#{non_unique_responses_count} !uniq"
        end,
      ].tap(&:compact!).join(separator)

      "Responses: #{counts}"
    end

    def describe_broadcast_counts(separator: ", ")
      counts = [
        if unique_broadcasts_count.positive?
          "#{unique_broadcasts_count} uniq"
        end,
        if non_unique_broadcasts_count.positive?
          "#{non_unique_broadcasts_count} !uniq"
        end,
      ].tap(&:compact!).join(separator)

      "Broadcasts: #{counts}"
    end

    def unique_responses_count = (response - broadcast).size
    def non_unique_responses_count = response.size - unique_responses_count

    def unique_broadcasts_count = (broadcast - response).size
    def non_unique_broadcasts_count = broadcast.size - unique_broadcasts_count
  end
end
