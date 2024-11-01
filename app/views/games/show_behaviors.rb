# frozen_string_literal: true

# Games::ShowBehaviors defines common code needed by the Games::* View models
# for showing {Game}-specific info.
module Games::ShowBehaviors
  include Games::StatusBehaviors

  def game_in_progress? = game.status_sweep_in_progress?
  def game_ended_in_victory? = game.ended_in_victory?
  def game_ended_in_defeat? = game.ended_in_defeat?

  def game_number = game.display_id

  def type = game.type

  private

  def game
    raise(NotImplementedError)
  end

  def game_id = game.id
end
