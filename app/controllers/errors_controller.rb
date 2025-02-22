# frozen_string_literal: true

class ErrorsController < ApplicationController
  after_action RecordVisit

  # 400
  def bad_request
    render(status: :bad_request)
  end

  # 404
  def not_found
    render(status: :not_found)
  end

  # 406
  def unsupported_browser
    @view = Errors::UnsupportedBrowser.new(context: layout)
    render(status: :not_acceptable)
  end

  # 422
  def unprocessable_entity
    render(status: :unprocessable_entity)
  end

  # 500
  def internal_server_error
    render(status: :internal_server_error)
  end
end
