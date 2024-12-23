# frozen_string_literal: true

# Home::Show represents the dynamic content of the home page / War Room.
class Home::Show
  def self.turbo_stream_name = WarRoomChannel::STREAM_NAME
  def self.turbo_stream_channel = WarRoomChannel

  def initialize(current_game:)
    @current_game = current_game
  end

  def welcome_banner(context:)
    Home::WelcomeBanner.new(context:)
  end

  def container
    if !current_game
      Games::New::Container.new
    elsif current_game.on?
      Games::Current::Container.new(current_game:)
    elsif current_game.just_ended?
      Games::JustEnded::Container.new(current_game:)
    end
  end

  private

  attr_reader :current_game
end
