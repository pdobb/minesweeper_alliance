# frozen_string_literal: true

require "test_helper"

class HoneybadgerTest < ActiveSupport::TestCase
  describe "#ignored_classes" do
    subject { Honeybadger.config }

    it "keeps the default ignored Rails exceptions" do
      _(subject.ignored_classes).must_include("ActionController::RoutingError")
    end

    it "ignores multipart requests that never reach the app" do
      _(subject.ignored_classes).must_include(
        "Rack::Multipart::BoundaryTooLongError",
      )
      _(subject.ignored_classes).must_include(
        "Rack::Multipart::MultipartPartLimitError",
      )
      _(subject.ignored_classes).must_include(
        "Rack::Multipart::MultipartTotalPartLimitError",
      )
    end
  end
end
