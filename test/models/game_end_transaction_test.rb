# frozen_string_literal: true

require "test_helper"

class GameEndTransactionTest < ActiveSupport::TestCase
  describe "GameEndTransaction" do
    let(:unit_class) { GameEndTransaction }

    let(:user1) { users(:user1) }

    let(:win1) { games(:win1) }
    let(:standing_by1) { games(:standing_by1) }

    describe ".create_between" do
      subject { unit_class }

      context "GIVEN a new, unique pair" do
        it "creates the expected record, and returns it" do
          result =
            _(-> {
              subject.create_between(user: user1, game: standing_by1)
            }).must_change("unit_class.count")
          _(result).must_be_instance_of(subject)
          _(result.user).must_be_same_as(user1)
          _(result.game).must_be_same_as(standing_by1)
        end

        it "caches the timestamp as Game#ended_at" do
          freeze_time do
            _(-> {
              subject.create_between(user: user1, game: standing_by1)
            }).must_change("standing_by1.ended_at", to: Time.current)
          end
        end
      end

      context "GIVEN an existing, non-unique pair" do
        it "raises ActiveRecord::RecordInvalid" do
          exception =
            _(-> {
              subject.create_between(user: user1, game: win1)
            }).must_raise(ActiveRecord::RecordInvalid)

          _(exception.message).must_equal(
            "Validation failed: Game has already been ended")
        end
      end
    end
  end
end
