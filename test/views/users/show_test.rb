# frozen_string_literal: true

require "test_helper"

class Users::ShowTest < ActiveSupport::TestCase
  describe "#time_zone" do
    subject { Users::Show.new(user:) }

    given "a profile stored as Asia/Calcutta" do
      let(:user) { User.new(time_zone: "Asia/Calcutta") }

      it "shows the Kolkata zone" do
        _(subject.time_zone).must_equal("(GMT+05:30) Kolkata")
      end
    end
  end

  describe "#local_time" do
    subject { Users::Show.new(user:) }

    given "a profile stored as Asia/Calcutta" do
      let(:user) { User.new(time_zone: "Asia/Calcutta") }
      let(:expected_local_time) {
        I18n.l(
          Time.current.in_time_zone("Asia/Kolkata"),
          format: :weekday_hours_minutes,
        )
      }

      it "formats the clock in Asia/Kolkata" do
        _(subject.local_time).must_equal(expected_local_time)
      end
    end

    given "a profile stored as an unknown zone" do
      let(:user) { User.new(time_zone: "Etc/Unknown") }

      it "returns nil" do
        _(subject.local_time).must_be_nil
      end
    end
  end
end
