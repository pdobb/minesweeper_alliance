# frozen_string_literal: true

require "test_helper"

class GameStartTransactionTest < ActiveSupport::TestCase
  let(:any_user) { users.sample }

  let(:win1) { games(:win1) }
  let(:standing_by1) { games(:standing_by1) }

  describe ".create_between" do
    subject { GameStartTransaction }

    given "a new, unique Game (regardless of what User)" do
      it "creates the expected record, and returns it" do
        result =
          _(-> {
            subject.create_between(user: any_user, game: standing_by1)
          }).must_change("GameStartTransaction.count")
        _(result).must_be_instance_of(subject)
        _(result.user).must_be_same_as(any_user)
        _(result.game).must_be_same_as(standing_by1)
      end

      it "caches the timestamp as Game#started_at" do
        freeze_time do
          _(-> {
            subject.create_between(user: any_user, game: standing_by1)
          }).must_change("standing_by1.started_at", to: Time.current)
        end
      end
    end

    given "an existing, non-unique Game (regardless of what User)" do
      it "raises ActiveRecord::RecordInvalid" do
        exception =
          _(-> {
            subject.create_between(user: any_user, game: win1)
          }).must_raise(ActiveRecord::RecordInvalid)

        _(exception.message).must_equal(
          "Validation failed: Game has already been started")
      end
    end
  end
end
