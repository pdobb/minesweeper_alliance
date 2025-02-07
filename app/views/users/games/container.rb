# frozen_string_literal: true

# Users::Games::Container represents past {Game}s in the context of a
# participating player ({User}).
class Users::Games::Container
  def self.cache_key(game:) = [:external_container, game]

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = Games::Past::Container.display_case_turbo_frame_name
  def cache_key = self.class.cache_key(game:)

  def content
    Users::Games::Content.new(game:, user:)
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
