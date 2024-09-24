# frozen_string_literal: true

require "test_helper"

class GridTest < ActiveSupport::TestCase
  describe "Grid" do
    let(:unit_class) { Grid }

    let(:mobile_context1) {
      Class.new { def mobile? = true }.new
    }
    let(:non_mobile_context1) {
      Class.new { def mobile? = false }.new
    }

    let(:tall_grid1) {
      [
        Coordinates[0, 0],
        Coordinates[0, 1],
      ]
    }
    let(:square_grid1) {
      # rubocop:disable Layout/MultilineArrayLineBreaks
      [
        Coordinates[0, 0], Coordinates[1, 0],
        Coordinates[0, 1], Coordinates[1, 1]
      ]
      # rubocop:enable Layout/MultilineArrayLineBreaks
    }
    let(:wide_grid1) {
      (Coordinates[0, 0]..Coordinates[1, 0]).to_a
    }
    let(:wide_grid2) {
      (Coordinates[1, 0]..Coordinates[10, 0]).to_a
    }
    let(:wide_grid3) {
      (Coordinates[1, 0]..Coordinates[11, 0]).to_a
    }

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
      context "GIVEN a mobile context" do
        let(:context) { mobile_context1 }

        context "GIVEN a tall Grid" do
          subject { unit_class.new(tall_grid1, context:) }

          it "returns the expected, non-transposed Array" do
            _(subject.to_a).must_equal([
              [Coordinates[0, 0]],
              [Coordinates[0, 1]],
            ])
          end
        end

        context "GIVEN a square Grid" do
          subject { unit_class.new(square_grid1, context:) }

          it "returns the expected, non-transposed Array" do
            _(subject.to_a).must_equal([
              [Coordinates[0, 0], Coordinates[1, 0]],
              [Coordinates[0, 1], Coordinates[1, 1]],
            ])
          end
        end

        context "GIVEN a wide Grid" do
          context "GIVEN #width <= 11" do
            let(:target) {
              [
                (Coordinates[1, 0]..Coordinates[10, 0]).to_a,
              ]
            }

            subject { unit_class.new(wide_grid2, context:) }

            it "returns the expected, non-transposed Array" do
              _(subject.to_a).must_equal(target)
            end
          end

          context "GIVEN #width > 11" do
            let(:target) {
              [
                (Coordinates[1, 0]..Coordinates[11, 0]).to_a,
              ].transpose
            }

            subject { unit_class.new(wide_grid3, context:) }

            it "returns the expected, transposed Array" do
              _(subject.to_a).must_equal(target)
            end
          end
        end
      end

      context "GIVEN a non-mobile context" do
        let(:context) { non_mobile_context1 }

        context "GIVEN a wide Grid" do
          subject { unit_class.new(wide_grid1, context:) }

          it "returns the expected, non-transposed Array" do
            _(subject.to_a).must_equal([
              [Coordinates[0, 0], Coordinates[1, 0]],
            ])
          end
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
