# frozen_string_literal: true

require "test_helper"

class GameTransactionTest < ActiveSupport::TestCase
  describe "GameTransaction" do
    let(:unit_class) { GameTransaction }

    let(:user1) { users(:user1) }
    let(:user2) { users(:user2) }

    let(:win1) { games(:win1) }
    let(:standing_by1) { games(:standing_by1) }

    describe "DB insertion (GIVEN no Rails validation)" do
      subject { GameStartTransaction.new(user: user1, game: win1) }

      it "raises ActiveRecord::RecordNotUnique" do
        exception =
          _(-> {
            subject.save(validate: false)
          }).must_raise(ActiveRecord::RecordNotUnique)

        _(exception.message).must_include(
          "PG::UniqueViolation: ERROR:  "\
          "duplicate key value violates unique constraint "\
          '"index_game_transactions_on_game_id_and_type"')
      end
    end

    describe ".create_between" do
      context "GIVEN a new, unique pair" do
        subject { GameStartTransaction }

        it "creates the expected GameTransaction record, and returns it" do
          result =
            _(-> {
              subject.create_between(user: user2, game: standing_by1)
            }).must_change("GameTransaction.count")
          _(result).must_be_instance_of(subject)
          _(result.user).must_be_same_as(user2)
          _(result.game).must_be_same_as(standing_by1)
        end
      end

      context "GIVEN an existing, non-unique pair" do
        subject { [GameStartTransaction, GameEndTransaction].sample }

        it "raises ActiveRecord::RecordInvalid" do
          exception =
            _(-> {
              subject.create_between(user: user1, game: win1)
            }).must_raise(ActiveRecord::RecordInvalid)

          _(exception.message).must_equal(
            "Validation failed: Game has already been taken")
        end
      end
    end

    describe ".exists_between?" do
      subject { unit_class }

      context "GIVEN an existing pair" do
        it "returns true" do
          result = subject.exists_between?(user: user1, game: win1)
          _(result).must_equal(true)
        end
      end

      context "GIVEN a non-existent pair" do
        it "returns false" do
          result = subject.exists_between?(user: user2, game: win1)
          _(result).must_equal(false)
        end
      end
    end
  end
end
