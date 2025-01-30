# frozen_string_literal: true

class ProfileController < ApplicationController
  def show
    @view = Profile::Show.new(user: current_user)
  end
end
