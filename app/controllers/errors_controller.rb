# frozen_string_literal: true

class ErrorsController < ApplicationController
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
