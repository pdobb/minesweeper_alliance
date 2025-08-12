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
    @unsupported_browser = Errors::UnsupportedBrowser.new(context: layout)
    render(status: :not_acceptable)
  end

  # 422
  def unprocessable_content
    render(status: :unprocessable_content)
  end

  # 500
  def internal_server_error
    render(status: :internal_server_error)
  end
end
