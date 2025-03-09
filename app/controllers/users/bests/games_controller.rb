# frozen_string_literal: true

class Users::Bests::GamesController < ApplicationController
  include AllowBrowserBehaviors

  before_action :require_user
  before_action :require_game

  def show
    @show = Users::Bests::Games::Show.new(game:, user:)
  end

  private

  attr_accessor :user,
                :game

  def require_user
    self.user = User.find_by(id: params[:user_id])
    head(:no_content) unless user
  end

  def require_game
    self.game = Game.find_by(id: params[:id])
    head(:no_content) unless game&.over?
  end
end
