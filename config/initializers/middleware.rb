# frozen_string_literal: true

# Compress HTML responses.
# See: https://andycroll.com/ruby/compress-your-rails-html-responses-on-heroku/
Rails.application.config.middleware.use Rack::Deflater
