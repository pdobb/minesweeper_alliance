# frozen_string_literal: true

# Users::Bests::Games::Container represents the entire view context surrounding
# a past{Game} in the context of a participating player's ({User}'s) "Bests"
# ({Game}s).
class Users::Bests::Games::Container
  def self.cache_key(game:) = [:user_bests_display_case, game]

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = Games::Past::Container.display_case_turbo_frame_name
  def cache_key = self.class.cache_key(game:)

  def content
    Users::Bests::Games::Content.new(game:, user:)
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
