# frozen_string_literal: true

require "test_helper"

class GameJoinTransactionTest < ActiveSupport::TestCase
  describe "GameJoinTransaction" do
    let(:unit_class) { GameJoinTransaction }

    let(:user1) { users(:user1) }
    let(:user2) { users(:user2) }
    let(:standing_by1) { games(:standing_by1) }

    describe ".create_between" do
      subject { unit_class }

      context "GIVEN a new, unique Game + User pair" do
        it "creates the expected record, and returns it" do
          result =
            _(-> {
              subject.create_between(user: user1, game: standing_by1)
            }).must_change("unit_class.count")
          _(result).must_be_instance_of(subject)
          _(result.user).must_be_same_as(user1)
          _(result.game).must_be_same_as(standing_by1)
        end
      end

      context "GIVEN an existing, non-unique Game + User pair" do
        it "fails validation" do
          result =
            _(-> {
              subject.create_between(user: user2, game: standing_by1)
            }).wont_change("unit_class.count")
          _(result.valid?).must_equal(false)
          _(result.errors[:game]).must_include(ValidationError.taken)
        end
      end
    end
  end
end
