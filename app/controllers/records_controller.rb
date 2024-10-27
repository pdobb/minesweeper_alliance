# frozen_string_literal: true

class RecordsController < ApplicationController
  def index
    @view = Records::Index.new
  end
end
