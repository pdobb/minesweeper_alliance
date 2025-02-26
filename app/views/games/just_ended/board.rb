# frozen_string_literal: true

# Games::JustEnded::Board is a specialization on {Games::Past::Board} that
# represents the {Board} for a just-ended {Game}.
class Games::JustEnded::Board < Games::Past::Board
  def scroll_position_storage_key = Home::Show.game_board_storage_key
end
