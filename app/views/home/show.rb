# frozen_string_literal: true

# Home::Show represents the dynamic content of the home page / War Room.
class Home::Show
  def self.turbo_stream_name = WarRoomChannel::STREAM_NAME
  def self.turbo_stream_channel = WarRoomChannel
  def self.turbo_stream_dom_id = "#{turbo_stream_name}_turbo_stream"

  # @param current_game [Game, NilClass]
  def initialize(current_game:)
    @current_game = current_game
  end

  def turbo_stream_name = self.class.turbo_stream_name
  def turbo_stream_channel = self.class.turbo_stream_channel
  def turbo_stream_dom_id = self.class.turbo_stream_dom_id

  def welcome_banner(context:)
    Home::WelcomeBanner.new(context: WelcomeBannerContext.new(context))
  end

  def container
    if current_game
      Games::Current::Container.new(game: current_game)
    else
      Games::New::Container.new
    end
  end

  def slide_menu(context:)
    Home::Roster::SlideMenu.new(context:)
  end

  def roster
    Home::Roster.new(game: current_game)
  end

  private

  attr_reader :current_game

  # Home::Show::WelcomeBannerContext services the needs of
  # {Home::WelcomeBanner}.
  class WelcomeBannerContext
    def initialize(context) = @context = context

    def current_user = context.current_user
    def show_welcome_banner? = Home::WelcomeBanner.show?(cookies)

    private

    attr_reader :context

    def cookies = context.cookies
  end
end
