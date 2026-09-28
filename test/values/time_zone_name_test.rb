# frozen_string_literal: true

require "test_helper"

class TimeZoneNameTest < ActiveSupport::TestCase
  describe ".canonical" do
    subject { TimeZoneName }

    given "the legacy Asia/Calcutta identifier" do
      it "returns the Rails name for Asia/Kolkata" do
        _(subject.canonical("Asia/Calcutta")).must_equal("Kolkata")
      end
    end

    given "a name Rails already accepts" do
      it "returns that name" do
        _(subject.canonical("Central Time (US & Canada)")).must_equal(
          "Central Time (US & Canada)",
        )
      end
    end

    given "a blank name" do
      it "returns nil" do
        _(subject.canonical(nil)).must_be_nil
      end
    end
  end
end
