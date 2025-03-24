# frozen_string_literal: true

require "test_helper"

class GameTransactionTest < ActiveSupport::TestCase
  let(:unit_class) { GameTransaction }

  let(:user1) { users(:user1) }
  let(:user2) { users(:user2) }

  let(:win1) { games(:win1) }
  let(:standing_by1) { games(:standing_by1) }

  describe "#save(validate: false)" do
    subject { unit_class.take }

    it "raises ActiveRecord::RecordNotUnique" do
      exception =
        _(-> {
          subject.dup.save(validate: false)
        }).must_raise(ActiveRecord::RecordNotUnique)

      _(exception.message).must_include(
        "PG::UniqueViolation: ERROR:  "\
        "duplicate key value violates unique constraint "\
        '"index_game_transactions_on_game_id_and_type"')
    end
  end

  describe ".create_between" do
    subject { unit_class }

    it "raises NotImplementedError" do
      _(-> {
        subject.create_between(user: user1, game: win1)
      }).must_raise(NotImplementedError)
    end
  end

  describe ".exists_between?" do
    subject { unit_class }

    given "an existing pair" do
      it "returns true" do
        result = subject.exists_between?(user: user1, game: win1)
        _(result).must_equal(true)
      end
    end

    given "a non-existent pair" do
      it "returns false" do
        result = subject.exists_between?(user: user2, game: win1)
        _(result).must_equal(false)
      end
    end
  end
end
