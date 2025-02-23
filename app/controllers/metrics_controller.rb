# frozen_string_literal: true

class MetricsController < ApplicationController
  include AllowBrowserBehaviors

  def show
    @show = Metrics::Show.new
  end
end
