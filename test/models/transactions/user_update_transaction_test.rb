# frozen_string_literal: true

require "test_helper"

class UserUpdateTransactionTest < ActiveSupport::TestCase
  let(:user1) { users(:user1) }

  let(:valid_change_set1) {
    { username: { old: "OLD", new: "NEW" } }
  }
  let(:empty_change_set1) { {} }

  describe "#validate" do
    describe "#change_set" do
      given "a #change_set" do
        subject { UserUpdateTransaction.new(change_set: valid_change_set1) }

        it "passes validation" do
          subject.validate

          _(subject.errors[:change_set]).must_be_empty
        end
      end

      given "no #change_set" do
        subject { UserUpdateTransaction.new(change_set: empty_change_set1) }

        it "fails validation" do
          subject.validate

          _(subject.errors[:change_set]).must_include(
            ValidationError.presence,
          )
        end
      end
    end
  end

  describe ".create_for" do
    subject { UserUpdateTransaction }

    it "creates the expected record, and returns it" do
      result =
        _(-> {
          subject.create_for(user: user1, change_set: valid_change_set1)
        }).must_change("UserUpdateTransaction.count")

      _(result).must_be_instance_of(subject)
      _(result.user).must_be_same_as(user1)
    end
  end
end
