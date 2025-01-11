# frozen_string_literal: true

class Games::JustEnded::FooterController < ApplicationController
  def show
    render(partial_options)
  end

  private

  def game
    Game.find(params[:game_id])
  end

  def partial_options
    PartialOptions.(game:, user: current_user)
  end

  # Games::JustEnded::FooterController::PartialOptions handles building out the
  # proper footer partial's rendering options based on whether or not the
  # passed-in {User} participated in, or was just a spectator of, the passed-in
  # {Game}.
  class PartialOptions
    include CallMethodBehaviors

    def initialize(game:, user:)
      @game = game
      @user = user
    end

    def call
      { partial:, locals: }
    end

    private

    attr_reader :game,
                :user

    def partial
      "games/just_ended/#{type}/footer"
    end

    def locals
      { footer: footer(type.camelize) }
    end

    def type
      @type ||= participant? ? "active_participants" : "observers"
    end

    def participant?
      @participant ||= user.participated_in?(game)
    end

    def footer(sub_type)
      "Games::JustEnded::#{sub_type}::Footer".constantize.new(game:, user:)
    end
  end
end
