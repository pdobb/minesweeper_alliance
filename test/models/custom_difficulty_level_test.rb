# frozen_string_literal: true

require "test_helper"

class CustomDifficultyLevelTest < ActiveSupport::TestCase
  describe "CustomDifficultyLevel" do
    let(:unit_class) { CustomDifficultyLevel }

    describe "#validate" do
      describe "#width" do
        subject { unit_class.new(width: width1) }

        context "GIVEN a valid #width" do
          let(:width1) { 9 }

          it "passes validation" do
            subject.validate
            _(subject.errors[:width]).must_be_empty
          end
        end

        context "GIVEN #width is not in the expected range" do
          let(:width1) { [2, 31].sample }

          it "fails validation" do
            subject.validate
            _(subject.errors[:width]).must_include(ValidationError.in(3..30))
          end
        end

        context "GIVEN #width is nil" do
          let(:width1) { nil }

          it "passes validation" do
            subject.validate
            _(subject.errors[:width]).must_include(ValidationError.presence)
          end
        end
      end

      describe "#height" do
        subject { unit_class.new(height: height1) }

        context "GIVEN a valid #height" do
          let(:height1) { 9 }

          it "passes validation" do
            subject.validate
            _(subject.errors[:height]).must_be_empty
          end
        end

        context "GIVEN #height is not in the expected range" do
          let(:height1) { [2, 31].sample }

          it "fails validation" do
            subject.validate
            _(subject.errors[:height]).must_include(ValidationError.in(3..30))
          end
        end

        context "GIVEN #height is nil" do
          let(:height1) { nil }

          it "passes validation" do
            subject.validate
            _(subject.errors[:height]).must_include(ValidationError.presence)
          end
        end
      end

      describe "#mines" do
        subject { unit_class.new(mines: mines1) }

        context "GIVEN a valid #mines" do
          let(:mines1) { 9 }

          it "passes validation" do
            subject.validate
            _(subject.errors[:mines]).must_be_empty
          end
        end

        context "GIVEN #mines is not in expected range" do
          let(:mines1) { [0, 226].sample }

          it "fails validation" do
            subject.validate
            _(subject.errors[:mines]).must_include(ValidationError.in(1..225))
          end
        end

        context "GIVEN #mines is nil" do
          let(:mines1) { nil }

          it "passes validation" do
            subject.validate
            _(subject.errors[:mines]).must_include(ValidationError.presence)
          end
        end
      end
    end

    context "GIVEN default values" do
      subject { unit_class.new }

      describe "#to_h" do
        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ width: 3, height: 3, mines: 1 })
        end
      end

      describe "#dimensions" do
        it "returns the expected String" do
          _(subject.dimensions).must_equal("3x3")
        end
      end

      describe "#width" do
        it "returns the expected Integer" do
          _(subject.width).must_equal(3)
        end
      end

      describe "#height" do
        it "returns the expected Integer" do
          _(subject.height).must_equal(3)
        end
      end

      describe "#mines" do
        it "returns the expected Integer" do
          _(subject.mines).must_equal(1)
        end
      end
    end

    context "GIVEN custom values" do
      subject { unit_class.new(width: 9, height: 9, mines: 9) }

      describe "#to_h" do
        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ width: 9, height: 9, mines: 9 })
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          _(subject.to_s).must_equal("Custom")
        end
      end

      describe "#dimensions" do
        it "returns the expected String" do
          _(subject.dimensions).must_equal("9x9")
        end
      end

      describe "#width" do
        it "returns the expected Integer" do
          _(subject.width).must_equal(9)
        end
      end

      describe "#height" do
        it "returns the expected Integer" do
          _(subject.height).must_equal(9)
        end
      end

      describe "#mines" do
        it "returns the expected Integer" do
          _(subject.mines).must_equal(9)
        end
      end
    end

    context "Regardless of GIVEN values" do
      subject { unit_class.new }

      describe "#name" do
        it "returns the expected String" do
          _(subject.name).must_equal("Custom")
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          _(subject.to_s).must_equal("Custom")
        end
      end

      describe "#initials" do
        it "returns the expected String" do
          _(subject.initials).must_equal("C")
        end
      end
    end
  end
end