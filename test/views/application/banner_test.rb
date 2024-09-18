# frozen_string_literal: true

require "test_helper"

class Application::BannerTest < ActiveSupport::TestCase
  describe "Application::Banner" do
    let(:unit_class) { Application::Banner }

    let(:banner1) {
      unit_class.new(content: { text: "Test 1." })
    }
    let(:banner2) {
      unit_class.new(content: { text: "Test 2." }, name: "test")
    }

    describe "#container_css_class" do
      subject { banner1 }

      it "returns an empty Array" do
        _(subject.container_css_class).must_be_empty
      end
    end

    describe "#button_css_class" do
      subject { banner1 }

      it "returns the expected String" do
        _(subject.button_css_class).must_include("text-gray-500")
      end
    end

    describe "#dismissable?" do
      context "GIVEN a name" do
        subject { banner2 }

        it "returns true" do
          _(subject.dismissable?).must_equal(true)
        end
      end

      context "GIVEN no name" do
        subject { banner1 }

        it "returns false" do
          _(subject.dismissable?).must_equal(false)
        end
      end
    end
  end
end
