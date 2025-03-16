# frozen_string_literal: true

class DevPortal::CookiesController < DevPortal::BaseController
  def show
    @show = DevPortal::Cookies::Show.new(context: self)
  end
end
