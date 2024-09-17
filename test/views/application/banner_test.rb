# frozen_string_literal: true

require "test_helper"

class Application::BannerTest < ActiveSupport::TestCase
  describe "Application::Banner" do
    let(:unit_class) { Application::Banner }

    let(:text_notification1) {
      unit_class.new(content: { text: "Test text." })
    }

    describe "#container_css_class" do
      subject { text_notification1 }

      it "returns an empty Array" do
        _(subject.container_css_class).must_be_empty
      end
    end

    describe "#button_css_class" do
      subject { text_notification1 }

      it "returns the expected String" do
        _(subject.button_css_class).must_include("text-gray-500")
      end
    end
  end
end
