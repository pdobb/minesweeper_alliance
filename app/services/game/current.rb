# frozen_string_literal: true

# Game::Current is responsible for look-up/creation of the "Current {Game}"
# record. Only one "Current {Game}" can exist at a time.
#
# The "Current Game" is the one with a "Game On" status:
# - Standing By
# - Sweep in Progress
#
# NOTE: While finding the current {Game} doesn't require a {User} record,
# creation does. And we can't be sure in advance if an existing record will be
# found or if a new record will need to be created. We rely on the database to
# determine as it can change from sub-second to sub-second!
class Game::Current
  def self.call(...) = new(...).call

  def self.exists? = Game.for_game_on_statuses.exists?

  def initialize(settings:, context:, &after_create_block)
    @settings = settings
    @context = context
    @after_create_block = after_create_block
  end

  # Essentially: #find_or_create
  def call
    find || create
  rescue ActiveRecord::RecordNotUnique
    # Handle race conditions on Game creation.
    retry
  end

  private

  attr_reader :settings,
              :context,
              :after_create_block

  def find
    Game::Current::Find.take
  end

  def create
    Create.(settings:, context:, &after_create_block)
  end
end
