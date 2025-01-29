# frozen_string_literal: true

class ProfileController < ApplicationController
  def show
    @view = Profile::Show.new(user: current_user)
  end

  def destroy
    clear_all_cookies
    redirect_to(root_path)
  end

  private

  def clear_all_cookies
    cookies.pluck(0).each { cookies.delete(it) }
  end
end
