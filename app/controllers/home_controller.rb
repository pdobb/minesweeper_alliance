# frozen_string_literal: true

class HomeController < ApplicationController
  include AllowBrowserBehaviors

  def show
    @view = Home::Show.new(current_game:)

    JoinGame.(user: current_user, game: current_game) if current_game
  end

  private

  def current_game = @current_game ||= Game::Current.find

  # HomeController::JoinGame manages what happens when a user joins (as in
  # visits, views, or otherwise witnesses) a {Game}.
  class JoinGame
    include CallMethodBehaviors

    def initialize(user:, game:)
      @user = user
      @game = game
    end

    def call
      return unless game

      ParticipantTransaction.create_between(user:, game:)
    end

    private

    attr_reader :user,
                :game
  end
end
