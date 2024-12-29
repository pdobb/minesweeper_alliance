# frozen_string_literal: true

class Games::JustEnded::FooterController < ApplicationController
  def show
    render(
      partial: "games/just_ended/footer",
      locals: { footer: })
  end

  private

  def footer
    Games::JustEnded::Footer.new(current_game:, user: current_user)
  end

  def current_game
    Game.find(params[:game_id])
  end
end
