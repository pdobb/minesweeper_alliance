# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Roster::Listing is a specialization on
# {Games::Past::ActiveParticipants::Roster::Listing} that represents an active
# participant ({User}) roster listing/entry for just-ended {Game}s.
class Games::JustEnded::ActiveParticipants::Roster::Listing <
        Games::Past::ActiveParticipants::Roster::Listing
  def show_current_user_indicator?(current_user)
    current_user.not_a_signer? && user == current_user
  end

  def updateable_display_name = View.updateable_display_name(user:)

  def show_user_url
    Router.user_path(user)
  end
end
