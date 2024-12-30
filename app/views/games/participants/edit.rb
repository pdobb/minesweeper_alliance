# frozen_string_literal: true

# Games::Participants::Edit represents the {User} "signature" form that shows at
# {Game} end for participating {User}s.
class Games::Participants::Edit
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = signature.turbo_frame_name

  def signature
    @signature ||= Games::Participants::Signature.new(game:, user:)
  end

  def form
    Games::Participants::Form.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
