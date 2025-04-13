# frozen_string_literal: true

# Home::Show represents the dynamic content of the home page / War Room.
class Home::Show
  def self.turbo_stream_name = WarRoomChannel::STREAM_NAME
  def self.turbo_stream_channel = WarRoomChannel
  def self.game_board_storage_key = "gameBoardDataStore"

  # @param current_game [Game, NilClass]
  def initialize(current_game:)
    @current_game = current_game
  end

  def to_param = self.class.turbo_stream_name
  def turbo_stream_channel = self.class.turbo_stream_channel

  def welcome_banner(context:)
    Home::WelcomeBanner.new(context: WelcomeBannerContext.new(context))
  end

  def game_board_storage_key = self.class.game_board_storage_key

  def container
    return Games::New::Container.new unless current_game

    if Game::Status.on?(current_game)
      Games::Current::Container.new(game: current_game)
    else
      Games::JustEnded::Container.new(game: current_game)
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

    def show_welcome_banner? = !current_user.ever_signed?

    private

    attr_reader :context

    def current_user = context.current_user
  end
end
