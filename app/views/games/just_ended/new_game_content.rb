# frozen_string_literal: true

# Games::JustEnded::NewGameContent stands in for {Games::New::Content} in order
# to always show the "Custom" button. We then use Stimulus JS to conditionally
# remove this button, per the appropriate current {User} state (see:
# app/javascript/controllers/games/just_ended/new_game_content_controller.js).
class Games::JustEnded::NewGameContent < Games::New::Content
  def show_new_custom_game_button?(_current_user)
    true
  end
end
