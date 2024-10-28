# frozen_string_literal: true

class MetricsController < ApplicationController
  def show
    @view = Metrics::Show.new
  end
end
