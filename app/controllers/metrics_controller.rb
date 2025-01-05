# frozen_string_literal: true

class MetricsController < ApplicationController
  include AllowBrowserBehaviors

  def show
    @view = Metrics::Show.new
  end
end
