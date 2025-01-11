# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::CurrentUser::Show represents the {User}
# "signature" line that shows at {Game} end for actively participating {User}s.
class Games::JustEnded::ActiveParticipants::CurrentUser::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::JustEnded::ActiveParticipants::Signature.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
