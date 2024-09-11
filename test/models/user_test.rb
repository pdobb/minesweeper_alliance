# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  describe "User" do
    let(:unit_class) { User }

    let(:user1) { users(:user1) }

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
  end
end
