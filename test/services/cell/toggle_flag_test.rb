# frozen_string_literal: true

require "test_helper"

class Cell::ToggleFlagTest < ActiveSupport::TestCase
  let(:win1_board_cell2) { cells(:win1_board_cell2) }
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
  let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }

  describe ".call" do
    subject { Cell::ToggleFlag }

    given "an already-revealed Cell" do
      let(:cell1) { win1_board_cell2 }

      it "returns nil and doesn't change any attributes on Cell" do
        result = _(-> { subject.call(cell1) }).wont_change("cell1.attributes")
        _(result).must_be_nil
      end
    end

    given "an unflagged Cell" do
      let(:cell1) { standing_by1_board_cell1 }

      it "sets the expected attributes" do
        result =
          _(-> {
            subject.call(cell1)
          }).must_change_all([
            ["cell1.flagged", to: true],
            ["cell1.updated_at"],
          ])
        _(result).must_be_same_as(cell1)
      end

      given "a highlighted Cell" do
        let(:cell1) {
          standing_by1_board_cell1.tap {
            it.update(highlighted: true)
          }
        }

        it "sets the expected attributes" do
          result =
            _(-> { subject.call(cell1) }).must_change_all([
              ["cell1.flagged", to: true],
              ["cell1.highlighted", to: false],
              ["cell1.updated_at"],
            ])
          _(result).must_be_same_as(cell1)
        end
      end
    end

    given "a flagged Cell" do
      let(:cell1) {
        standing_by1_board_cell1.tap { it.update(flagged: true) }
      }

      it "sets the expected attributes" do
        result =
          _(-> {
            subject.call(cell1)
          }).must_change_all([
            ["cell1.flagged", to: false],
            ["cell1.updated_at"],
          ])
        _(result).must_be_same_as(cell1)
      end

      given "a highlighted Cell" do
        let(:cell1) {
          standing_by1_board_cell1.tap {
            it.update(flagged: true, highlighted: true)
          }
        }

        it "sets the expected attributes" do
          result =
            _(-> {
              _(-> { subject.call(cell1) }).wont_change("cell1.highlighted")
            }).must_change_all([
              ["cell1.flagged", to: false],
              ["cell1.updated_at"],
            ])
          _(result).must_be_same_as(cell1)
        end
      end
    end
  end
end
