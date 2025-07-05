# frozen_string_literal: true

require "test_helper"

class GameCreateTransactionTest < ActiveSupport::TestCase
  let(:any_user) { users.sample }
  let(:standing_by1) { games(:standing_by1) }

  describe ".create_between" do
    subject { GameCreateTransaction }

    given "a new, unique Game (regardless of what User)" do
      before do
        standing_by1.game_create_transaction.delete
        standing_by1.game_create_transaction = nil
      end

      it "creates the expected record, and returns it" do
        result =
          _(-> {
            subject.create_between(user: any_user, game: standing_by1)
          }).must_change("GameCreateTransaction.count")

        _(result).must_be_instance_of(subject)
        _(result.user).must_be_same_as(any_user)
        _(result.game).must_be_same_as(standing_by1)
      end
    end

    given "an existing, non-unique Game (regardless of what User)" do
      it "raises ActiveRecord::RecordInvalid" do
        exception =
          _(-> {
            subject.create_between(user: any_user, game: standing_by1)
          }).must_raise(ActiveRecord::RecordInvalid)

        _(exception.message).must_equal(
          "Validation failed: Game has already been created")
      end
    end
  end
end
