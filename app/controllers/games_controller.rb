# frozen_string_literal: true

class GamesController < ApplicationController
  include AllowBrowserBehaviors

  after_action RecordVisit, only: %i[index create]

  def index
    @index =
      Games::Index.new(
        base_arel: Game.for_game_over_statuses.is_not_spam,
        context: layout)
  end

  def show
    if (game = Game.find_by(id: params[:id]))
      redirect_to(root_path) and return if Game::Status.on?(game)

      @show = Games::Show.new(game:)
    else
      redirect_to({ action: :index }, alert: t("flash.not_found", type: "Game"))
    end
  end

  def new
    @new = Games::New.new
  end

  def create
    settings = Board::Settings.preset(params[:preset])
    Game::Current.(settings:, context: CurrentGameContext.new(self))

    redirect_to(root_path)
  end

  # GamesController::CurrentGameContext services the needs of
  # {Game::Current} and, by extension, {Game::Current::BeforeCreate}.
  class CurrentGameContext
    def initialize(context) = @context = context
    def layout = context.layout

    def user_agent = layout.user_agent
    def store_signed_cookie(...) = layout.store_signed_cookie(...)
    def delete_cookie(...) = layout.cookies.delete(...)

    def user = context.current_user
    def current_user_will_change = context.current_user_will_change

    private

    attr_reader :context
  end
end
