# frozen_string_literal: true

class UIPortal::HomeController < ApplicationController
  def show
    %i[alert notice info warning].each do |type|
      flash.now[type] = "Test #{type}."
    end
  end
end
