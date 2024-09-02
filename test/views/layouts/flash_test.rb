# frozen_string_literal: true

require "test_helper"

class Layouts::FlashTest < ActiveSupport::TestCase
  describe "Layouts::Flash" do
    let(:unit_class) { Layouts::Flash }

    let(:flash_hash) { ActionDispatch::Flash::FlashHash.new }

    def build_flash(type)
      flash_hash.public_send(:"#{type}=", "Test #{type}.")
      flash_hash
    end

    describe "#notifications" do
      subject { unit_class.new(build_flash(:notice)) }

      it "returns an Array of Layouts::Flash::Notifications" do
        result = subject.notifications
        _(result).must_be_instance_of(Array)
        _(result.sample).must_be_instance_of(Layouts::Flash::Notification)
      end
    end

    describe "Notification" do
      let(:unit_class) { Layouts::Flash::Notification }

      let(:notice_notification) {
        unit_class.new(type: :notice, message: "Test notice.")
      }
      let(:alert_notification) {
        unit_class.new(type: :alert, message: "Test alert.")
      }
      let(:info_notification) {
        unit_class.new(type: :info, message: "Test info.")
      }
      let(:warning_notification) {
        unit_class.new(type: :warning, message: "Test warning.")
      }

      describe "#container_css_class" do
        context "GIVEN type = :notice" do
          subject { notice_notification }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-green-800")
          end
        end

        context "GIVEN type = :alert" do
          subject { alert_notification }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-red-800")
          end
        end

        context "GIVEN type = :info" do
          subject { info_notification }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-blue-800")
          end
        end

        context "GIVEN type = :warning" do
          subject { warning_notification }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-yellow-800")
          end
        end
      end

      describe "#button_css_class" do
        context "GIVEN type = :notice" do
          subject { notice_notification }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-green-500")
          end
        end

        context "GIVEN type = :alert" do
          subject { alert_notification }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-red-500")
          end
        end

        context "GIVEN type = :info" do
          subject { info_notification }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-blue-500")
          end
        end

        context "GIVEN type = :warning" do
          subject { warning_notification }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-yellow-500")
          end
        end
      end
    end
  end
end
