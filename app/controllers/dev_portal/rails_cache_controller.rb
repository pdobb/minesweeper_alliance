# frozen_string_literal: true

class DevPortal::RailsCacheController < DevPortal::BaseController
  def show
    @show = DevPortal::RailsCache::Show.new
  end
end
