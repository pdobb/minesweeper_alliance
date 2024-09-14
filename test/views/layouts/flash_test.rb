# frozen_string_literal: true

require "test_helper"

class Layouts::FlashTest < ActiveSupport::TestCase
  describe "Layouts::Flash" do
    let(:unit_class) { Layouts::Flash }

    let(:flash_hash) { ActionDispatch::Flash::FlashHash.new }

    describe "#notifications" do
      context "GIVEN a single, simple flash notification" do
        subject {
          flash_hash.now[:notice] = "Test notice."
          unit_class.new(flash_hash)
        }

        it "returns an Array of Layouts::Flash::Notifications" do
          result = subject.notifications
          _(result).must_be_instance_of(Array)
          _(result.size).must_equal(1)
          _(result.sample).must_be_instance_of(Layouts::Flash::Notification)
        end
      end

      context "GIVEN multiple, simple flash notification" do
        subject {
          flash_hash.now[:notice] = ["Test notice 1.", "Test notice 2."]
          unit_class.new(flash_hash)
        }

        it "returns an Array of Layouts::Flash::Notifications" do
          result = subject.notifications
          _(result).must_be_instance_of(Array)
          _(result.size).must_equal(2)
          _(result.sample).must_be_instance_of(Layouts::Flash::Notification)
        end
      end

      context "GIVEN multiple, complex flash notification" do
        subject {
          flash_hash.now[:notice] = [
            { text: "Test notice 1.", timeout: 3 },
            { text: "Test notice 2.", timeout: 3 },
          ]
          unit_class.new(flash_hash)
        }

        it "returns an Array of Layouts::Flash::Notifications" do
          result = subject.notifications
          _(result).must_be_instance_of(Array)
          _(result.size).must_equal(2)
          _(result.sample).must_be_instance_of(Layouts::Flash::Notification)
        end
      end
    end

    describe "Notification" do
      let(:unit_class) { Layouts::Flash::Notification }

      let(:notice_notification1) {
        unit_class.new(type: :notice, message: "Test notice.")
      }
      let(:alert_notification1) {
        unit_class.new(type: :alert, message: "Test alert.")
      }
      let(:info_notification1) {
        unit_class.new(type: :info, message: "Test info.")
      }
      let(:warning_notification1) {
        unit_class.new(type: :warning, message: "Test warning.")
      }

      describe "#container_css_class" do
        context "GIVEN type = :notice" do
          subject { notice_notification1 }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-green-800")
          end
        end

        context "GIVEN type = :alert" do
          subject { alert_notification1 }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-red-800")
          end
        end

        context "GIVEN type = :info" do
          subject { info_notification1 }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-blue-800")
          end
        end

        context "GIVEN type = :warning" do
          subject { warning_notification1 }

          it "returns the expected String" do
            _(subject.container_css_class).must_include("text-yellow-800")
          end
        end
      end

      describe "#button_css_class" do
        context "GIVEN type = :notice" do
          subject { notice_notification1 }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-green-500")
          end
        end

        context "GIVEN type = :alert" do
          subject { alert_notification1 }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-red-500")
          end
        end

        context "GIVEN type = :info" do
          subject { info_notification1 }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-blue-500")
          end
        end

        context "GIVEN type = :warning" do
          subject { warning_notification1 }

          it "returns the expected String" do
            _(subject.button_css_class).must_include("text-yellow-500")
          end
        end
      end

      describe "#timeout_in_milliseconds" do
        context "GIVEN no timeout value (using defaults)" do
          subject { notice_notification1 }

          it "returns the expected Integer" do
            _(subject.timeout_in_milliseconds).must_equal(10_000)
          end
        end

        context "GIVEN a timeout value" do
          subject {
            unit_class.new(
              type: :notice,
              message: { text: "Test notice.", timeout: 9 })
          }

          it "returns the expected Integer" do
            _(subject.timeout_in_milliseconds).must_equal(9_000)
          end
        end

        context "GIVEN a falsy timeout value" do
          subject {
            unit_class.new(
              type: :notice,
              message: { text: "Test notice.", timeout: [nil, false].sample })
          }

          it "returns the expected Integer" do
            _(subject.timeout_in_milliseconds).must_be_nil
          end
        end
      end

      describe "#timeout?" do
        context "GIVEN no timeout value (using defaults)" do
          subject { notice_notification1 }

          it "returns true" do
            _(subject.timeout?).must_equal(true)
          end
        end

        context "GIVEN a timeout value" do
          subject {
            unit_class.new(
              type: :notice,
              message: { text: "Test notice.", timeout: [0, 9].sample })
          }

          it "returns true" do
            _(subject.timeout?).must_equal(true)
          end
        end

        context "GIVEN a falsy timeout value" do
          subject {
            unit_class.new(
              type: :notice,
              message: { text: "Test notice.", timeout: [nil, false].sample })
          }

          it "returns false" do
            _(subject.timeout?).must_equal(false)
          end
        end
      end
    end
  end
end
