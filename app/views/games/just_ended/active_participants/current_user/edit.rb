# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::CurrentUser::Edit represents the {User}
# "signature" form that shows at {Game} end for actively participating {User}s.
class Games::JustEnded::ActiveParticipants::CurrentUser::Edit
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = signature.turbo_frame_name

  def signature
    @signature ||=
      Games::JustEnded::ActiveParticipants::Signature.new(game:, user:)
  end

  def form
    Games::JustEnded::ActiveParticipants::CurrentUser::Form.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
