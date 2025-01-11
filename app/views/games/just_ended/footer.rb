# frozen_string_literal: true

# Games::JustEnded::Footer is a stand-in module for either
# {Games::JustEnded::ActiveParticipants::Footer} or
# {Games::JustEnded::Observers::Footer}--for before we know which will be
# selected/used by {Games::JustEnded::FooterController}.
module Games::JustEnded::Footer
  def self.turbo_frame_name(game) = [game, :just_ended_footer]
end
