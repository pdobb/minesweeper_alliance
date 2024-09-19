# frozen_string_literal: true

require "test_helper"

class Application::PermanentlyDismissableBannerTest < ActiveSupport::TestCase
  describe "Application::PermanentlyDismissableBanner" do
    let(:unit_class) { Application::PermanentlyDismissableBanner }

    let(:banner1) {
      unit_class.new(
        name: "test_banner",
        content: { text: "Test 1." },
        context: context1)
    }
    let(:context1) {
      Class.new { def show_banner_dismissal_button? = true }.new
    }

    let(:banner2) {
      unit_class.new(
        name: "test_banner",
        content: { text: "Test 2." },
        context: context2)
    }
    let(:context2) {
      Class.new { def show_banner_dismissal_button? = false }.new
    }

    describe "#name" do
      subject { banner1 }

      it "returns the expected String" do
        _(subject.name).must_include("test_banner")
      end
    end

    describe "#button_css_class" do
      subject { banner1 }

      it "returns the expected String" do
        _(subject.button_css_class).must_include("text-gray-500")
      end
    end

    describe "#show_dismissal_button?" do
      context "GIVEN #context.show_banner_dismissal_button? = true" do
        subject { banner1 }

        it "returns true" do
          _(subject.show_dismissal_button?).must_equal(true)
        end
      end

      context "GIVEN #context.show_banner_dismissal_button? = false" do
        subject { banner2 }

        it "returns false" do
          _(subject.show_dismissal_button?).must_equal(false)
        end
      end
    end

    describe "#permanently_dismissable?" do
      subject { banner1 }

      it "returns true" do
        _(subject.permanently_dismissable?).must_equal(true)
      end
    end
  end
end
