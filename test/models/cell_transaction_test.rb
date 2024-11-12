# frozen_string_literal: true

require "test_helper"

class CellTransactionTest < ActiveSupport::TestCase
  describe "CellTransaction" do
    let(:unit_class) { CellTransaction }

    let(:user1) { users(:user1) }
    let(:win1_board_cell2) { cells(:win1_board_cell2) }
    let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }

    let(:win1_cell_reveal_transaction1) {
      cell_transactions(:win1_cell_reveal_transaction1)
    }

    describe "DB insertion (GIVEN no Rails validation)" do
      subject { CellRevealTransaction.new(user: user1, cell: win1_board_cell2) }

      it "raises ActiveRecord::RecordNotUnique" do
        exception =
          _(-> {
            subject.save(validate: false)
          }).must_raise(ActiveRecord::RecordNotUnique)

        _(exception.message).must_include(
          "PG::UniqueViolation: ERROR:  "\
          "duplicate key value violates unique constraint "\
          '"index_cell_transactions_on_cell_id_and_type"')
      end
    end

    describe ".create_between" do
      context "GIVEN a new, unique pair" do
        subject { CellRevealTransaction }

        it "creates the expected CellTransaction record, and returns it" do
          result =
            _(-> {
              subject.create_between(
                user: user1, cell: standing_by1_board_cell1)
            }).must_change("CellTransaction.count")
          _(result).must_be_instance_of(subject)
          _(result.user).must_be_same_as(user1)
          _(result.cell).must_be_same_as(standing_by1_board_cell1)
        end
      end

      context "GIVEN an existing, non-unique pair" do
        subject { CellRevealTransaction }

        it "raises ActiveRecord::RecordInvalid" do
          exception =
            _(-> {
              subject.create_between(user: user1, cell: win1_board_cell2)
            }).must_raise(ActiveRecord::RecordInvalid)

          _(exception.message).must_equal(
            "Validation failed: Cell has already been taken")
        end
      end
    end

    describe ".exists_between?" do
      subject { unit_class }

      context "GIVEN an existing CellTransaction" do
        let(:win1_board_cell2) { cells(:win1_board_cell2) }

        it "returns true" do
          result = subject.exists_between?(user: user1, cell: win1_board_cell2)
          _(result).must_equal(true)
        end
      end

      context "GIVEN no existing CellTransaction" do
        it "returns false" do
          result =
            subject.exists_between?(user: user1, cell: standing_by1_board_cell1)
          _(result).must_equal(false)
        end
      end
    end
  end
end
