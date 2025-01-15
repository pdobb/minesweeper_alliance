# frozen_string_literal: true

class HomeController < ApplicationController
  include AllowBrowserBehaviors

  def show
    @view = Home::Show.new(current_game:)

    JoinGame.(user: current_user, game: current_game)
  end

  private

  def current_game = @current_game ||= Game.current

  # HomeController::JoinGame
  class JoinGame
    include CallMethodBehaviors

    def initialize(user:, game:)
      @user = user
      @game = game
    end

    def call
      return unless game

      GameJoinTransaction.create_between(user:, game:)
    end

    private

    attr_reader :user,
                :game
  end
end
