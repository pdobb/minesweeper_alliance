# frozen_string_literal: true

# Games::ShowBehaviors defines common code needed by the Games::* View models
# for showing {Game}-specific info.
module Games::ShowBehaviors
  include Games::StatusBehaviors

  def game_in_progress? = to_model.status_sweep_in_progress?
  def game_ended_in_victory? = to_model.ended_in_victory?
  def game_ended_in_defeat? = to_model.ended_in_defeat?

  def game_number
    game_id.to_s.rjust(4, "0")
  end

  def difficulty_level = to_model.difficulty_level

  private

  def to_model
    raise(NotImplementedError)
  end

  def game_id = to_model.id
end
