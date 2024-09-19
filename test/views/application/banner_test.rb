# frozen_string_literal: true

require "test_helper"

class Application::BannerTest < ActiveSupport::TestCase
  describe "Application::Banner" do
    let(:unit_class) { Application::Banner }

    let(:banner1) {
      unit_class.new(content: { text: "Test 1." })
    }

    describe "#button_css_class" do
      subject { banner1 }

      it "returns the expected String" do
        _(subject.button_css_class).must_include("text-gray-500")
      end
    end

    describe "#show_dismissal_button?" do
      context "GIVEN a #context" do
        subject {
          unit_class.new(content: { text: "Test 1." }, context:)
        }

        context "GIVEN #context.show_banner_dismissal_button? = true" do
          let(:context) {
            Class.new { def show_banner_dismissal_button? = true }.new
          }

          it "returns true" do
            _(subject.show_dismissal_button?).must_equal(true)
          end
        end

        context "GIVEN #context.show_banner_dismissal_button? = false" do
          let(:context) {
            Class.new { def show_banner_dismissal_button? = false }.new
          }

          it "returns false" do
            _(subject.show_dismissal_button?).must_equal(false)
          end
        end
      end

      context "GIVEN no #context" do
        subject { banner1 }

        it "returns true" do
          _(subject.show_dismissal_button?).must_equal(true)
        end
      end
    end

    describe "#permanently_dismissable?" do
      subject { banner1 }

      it "returns false" do
        _(subject.permanently_dismissable?).must_equal(false)
      end
    end
  end
end
