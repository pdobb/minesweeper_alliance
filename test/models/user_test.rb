# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "User" do
    let(:unit_class) { User }

    let(:user1) { users(:user1) }
    let(:user2) { users(:user2) }

    describe ".first" do
      subject { unit_class }

      it "returns the expected User (ordered by 'created_at')" do
        _(subject.first).must_equal(user1)
      end
    end

    describe "#id" do
      subject { user1 }

      it "is a GUID" do
        result = subject.id
        _(result).must_be_instance_of(String)
      end
    end

    describe "#display_name" do
      context "GIVEN #username.present? = true" do
        subject { user1 }

        it "returns the expected String" do
          _(subject.display_name).must_match(/MMS-\d{4} "User1"/)
        end
      end

      context "GIVEN #username.blank? = true" do
        subject { user2 }

        it "returns the expected String" do
          _(subject.display_name).must_match(/MMS-\d{4}/)
        end
      end
    end

    describe "#unique_id" do
      before do
        MuchStub.(subject, :created_at) {
          Time.zone.local(2024, 1, 1, 12, 34, 56)
        }
      end

      subject { user1 }

      it "returns the expected String" do
        _(subject.unique_id).must_equal("4096")
      end
    end
  end
end
