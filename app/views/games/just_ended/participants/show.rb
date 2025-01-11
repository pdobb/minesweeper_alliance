# frozen_string_literal: true

# Games::JustEnded::Participants::Show represents the {User} "signature" line
# that shows at {Game} end for participating {User}s.
class Games::JustEnded::Participants::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::JustEnded::Participants::Signature.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
