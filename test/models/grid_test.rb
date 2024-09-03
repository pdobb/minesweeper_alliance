# frozen_string_literal: true

require "test_helper"

class GridTest < ActiveSupport::TestCase
  describe "Grid" do
    let(:unit_class) { Grid }

    context "Class Methods" do
      subject { unit_class }

      describe ".build_for" do
        context "GIVEN a Mobile context" do
          let(:context) {
            Class.new { def mobile? = true }.new
          }

          it "builds a Grid that uses the 'Transpose' organizer" do
            result = subject.build_for([1, 2, 3], context:)
            _(result).must_be_instance_of(unit_class)
            _(result.organizer).must_equal(unit_class::TRANSPOSE_ORGANIZER)
          end
        end

        context "GIVEN a non-Mobile context" do
          let(:context) {
            Class.new { def mobile? = false }.new
          }

          it "builds a Grid that uses the 'Transpose' organizer" do
            result = subject.build_for([1, 2, 3], context:)
            _(result).must_be_instance_of(unit_class)
            _(result.organizer).must_equal(unit_class::STANDARD_ORGANIZER)
          end
        end

        context "GIVEN a nil context" do
          let(:context) { nil }

          it "builds a Grid that uses the 'Transpose' organizer" do
            result = subject.build_for([1, 2, 3], context:)
            _(result).must_be_instance_of(unit_class)
            _(result.organizer).must_equal(unit_class::STANDARD_ORGANIZER)
          end
        end
      end
    end

    describe "#cells" do
      context "GIVEN an Array of Cells" do
        subject { unit_class.new([1, 2, 3]) }

        it "returns the expected Array" do
          _(subject.cells).must_equal([1, 2, 3])
        end
      end

      context "GIVEN a Cell" do
        subject { unit_class.new(1) }

        it "returns the expected Array" do
          _(subject.cells).must_equal([1])
        end
      end
    end

    describe "#cells_count" do
      subject { unit_class.new([Coordinates[9, 9]]) }

      it "returns the expected Integer" do
        _(subject.cells_count).must_equal(1)
      end
    end

    describe "#to_h" do
      context "GIVEN Cell#y is not nil" do
        subject { unit_class.new([Coordinates[9, 9]]) }

        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ 9 => [Coordinates[9, 9]] })
        end
      end

      context "GIVEN Cell#y is nil" do
        subject { unit_class.new([Coordinates[nil, nil]]) }

        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ "nil" => [Coordinates[nil, nil]] })
        end
      end
    end

    describe "#to_a" do
      let(:cells1) {
        # rubocop:disable Layout/MultilineArrayLineBreaks
        [
          Coordinates[0, 0], Coordinates[0, 1],
          Coordinates[1, 0], Coordinates[1, 1]
        ]
        # rubocop:enable Layout/MultilineArrayLineBreaks
      }

      context "GIVEN the Grid::STANDARD_ORGANIZER" do
        subject { unit_class.new(cells1, organizer: Grid::STANDARD_ORGANIZER) }

        it "returns the expected Array" do
          _(subject.to_a).must_equal([
            [Coordinates[0, 0], Coordinates[1, 0]],
            [Coordinates[0, 1], Coordinates[1, 1]],
          ])
        end
      end

      context "GIVEN the Grid::TRANSPOSE_ORGANIZER" do
        subject { unit_class.new(cells1, organizer: Grid::TRANSPOSE_ORGANIZER) }

        it "returns the expected Array" do
          _(subject.to_a).must_equal([
            [Coordinates[0, 0], Coordinates[0, 1]],
            [Coordinates[1, 0], Coordinates[1, 1]],
          ])
        end
      end
    end

    describe "#map" do
      subject { unit_class.new([Coordinates[9, 9]]) }

      it "returns an enumerator, GIVEN no block" do
        _(subject.map).must_be_instance_of(Enumerator)
      end

      it "returns the expected mapping, GIVEN a block" do
        result = subject.map { |array| array.map(&:y) }
        _(result).must_equal([[9]])
      end
    end
  end
end
