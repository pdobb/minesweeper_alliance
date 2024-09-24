# frozen_string_literal: true

require "test_helper"

class Board::SettingsTest < ActiveSupport::TestCase
  describe "Board::Settings" do
    let(:unit_class) { Board::Settings }

    context "Class Methods" do
      subject { unit_class }

      describe ".preset" do
        context "GIVEN a valid name" do
          let(:name1) { ["Beginner", "intermediate", :expert].sample }

          it "returns the expected instance" do
            result = subject.preset(name1)
            _(result).must_be_instance_of(unit_class)
            _(unit_class::PRESETS.keys).must_include(result.name)
          end
        end

        context "GIVEN an unknown name" do
          it "raises KeyError" do
            exception = _(-> { subject.preset("UNKNOWN") }).must_raise(KeyError)
            _(exception.message).must_equal('key not found: "Unknown"')
          end
        end

        context "GIVEN name = nil" do
          it "raises TypeError" do
            exception = _(-> { subject.preset(nil) }).must_raise(TypeError)
            _(exception.message).must_equal("name can't be blank")
          end
        end
      end

      describe ".beginner" do
        it "returns the expected instance" do
          result = subject.beginner
          _(result).must_be_instance_of(unit_class)
          _(result.name).must_equal("Beginner")
        end
      end
      describe ".intermediate" do
        it "returns the expected instance" do
          result = subject.intermediate
          _(result).must_be_instance_of(unit_class)
          _(result.name).must_equal("Intermediate")
        end
      end
      describe ".expert" do
        it "returns the expected instance" do
          result = subject.expert
          _(result).must_be_instance_of(unit_class)
          _(result.name).must_equal("Expert")
        end
      end

      describe ".random" do
        it "returns a random preset" do
          result = subject.random
          _(result).must_be_instance_of(unit_class)
          _(unit_class::PRESETS.keys).must_include(result.name)
        end
      end
    end

    describe "#validate" do
      describe "#width" do
        subject { unit_class[width1, 9, 4] }

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
            _(subject.errors[:width]).must_include(ValidationError.in(6..30))
          end
        end

        context "GIVEN #width is nil" do
          let(:width1) { nil }

          it "fails validation" do
            subject.validate
            _(subject.errors[:width]).must_include(ValidationError.presence)
          end
        end
      end

      describe "#height" do
        subject { unit_class[9, height1, 4] }

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
            _(subject.errors[:height]).must_include(ValidationError.in(6..30))
          end
        end

        context "GIVEN #height is nil" do
          let(:height1) { nil }

          it "fails validation" do
            subject.validate
            _(subject.errors[:height]).must_include(ValidationError.presence)
          end
        end
      end

      describe "#mines" do
        subject { unit_class[9, 9, mines1] }

        context "GIVEN a valid #mines" do
          let(:mines1) { 10 }

          it "passes validation" do
            subject.validate
            _(subject.errors[:mines]).must_be_empty
          end
        end

        context "GIVEN #mines is not in expected range" do
          let(:mines1) { [3, 300].sample }

          it "fails validation" do
            subject.validate
            _(subject.errors[:mines]).must_include(ValidationError.in(4..299))
          end
        end

        context "GIVEN #mines is nil" do
          let(:mines1) { nil }

          it "fails validation" do
            subject.validate
            _(subject.errors[:mines]).must_include(ValidationError.presence)
          end
        end

        context "GIVEN other validation errors present" do
          subject { unit_class[-1, 9, mines1] }

          context "GIVEN too many #mines" do
            let(:mines1) { 99 }

            it "fails validation, but not due to density" do
              subject.validate
              _(subject.errors[:mines]).wont_include(
                "must be <= 12 (1/3 of total area)")
            end
          end

          context "GIVEN too few #mines" do
            let(:mines1) { 3 }

            it "fails validation, but not due to sparseness" do
              subject.validate
              _(subject.errors[:mines]).wont_include(
                "must be >= 9 (10% of total area)")
            end
          end
        end

        context "GIVEN no other validation errors present" do
          subject { unit_class[9, 9, mines1] }

          context "GIVEN too many #mines" do
            let(:mines1) { 99 }

            it "fails validation" do
              subject.validate
              _(subject.errors[:mines]).must_include(
                "must be <= 27 (1/3 of total area)")
            end
          end

          context "GIVEN too few #mines" do
            let(:mines1) { 4 }

            it "fails validation" do
              subject.validate
              _(subject.errors[:mines]).must_include(
                "must be >= 9 (10% of total area)")
            end
          end
        end
      end
    end

    context "GIVEN a preset" do
      subject { unit_class.beginner }

      describe "#name" do
        it "returns the expected String" do
          _(subject.name).must_equal("Beginner")
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
          _(subject.mines).must_equal(10)
        end
      end

      describe "#to_h" do
        it "returns the expected Hash" do
          _(subject.to_h).must_equal(
            { name: "Beginner", width: 9, height: 9, mines: 10 })
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          _(subject.to_s).must_equal("Beginner")
        end
      end
    end

    context "GIVEN custom attributes" do
      subject { unit_class[6, 6, 9] }

      describe "#name" do
        it "returns the expected String" do
          _(subject.name).must_equal("Custom")
        end
      end

      describe "#to_h" do
        it "returns the expected Hash" do
          _(subject.to_h).must_equal(
            { name: "Custom", width: 6, height: 6, mines: 9 })
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          _(subject.to_s).must_equal("Custom")
        end
      end
    end
  end
end