# frozen_string_literal: true

# Metrics::Participants::MostActive::Listing represents "Active  Participant"
# listings in the Metrics -> Minesweepers -> Most Active table.
class Metrics::Participants::MostActive::Listing
  include WrapMethodBehaviors

  def initialize(user)
    @user = user
  end

  def active_participation_count = user.active_participation_count

  def name = username || mms_id
  def user_url = Router.user_path(user)

  def title? = username?
  def title = user.display_name

  private

  attr_reader :user

  def username? = user.username?
  def username = user.username
  def mms_id = user.mms_id
end
