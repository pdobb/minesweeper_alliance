# frozen_string_literal: true

require "test_helper"

class Board::SettingsTest < ActiveSupport::TestCase
  describe "Board::Settings" do
    let(:unit_class) { Board::Settings }

    context "Class Methods" do
      subject { unit_class }

      describe ".preset" do
        context "GIVEN a valid type" do
          let(:type1) { ["Beginner", "intermediate", :expert].sample }

          it "returns the expected instance" do
            result = subject.preset(type1)
            _(result).must_be_instance_of(unit_class)
            _(unit_class::PRESETS.keys).must_include(result.type)
          end
        end

        context "GIVEN an unknown type" do
          it "raises KeyError" do
            exception = _(-> { subject.preset("UNKNOWN") }).must_raise(KeyError)
            _(exception.message).must_equal('key not found: "Unknown"')
          end
        end

        context "GIVEN type = nil" do
          it "raises TypeError" do
            exception = _(-> { subject.preset(nil) }).must_raise(TypeError)
            _(exception.message).must_equal("type can't be blank")
          end
        end
      end

      describe ".beginner" do
        it "returns the expected instance" do
          result = subject.beginner
          _(result).must_be_instance_of(unit_class)
          _(result.type).must_equal("Beginner")
        end
      end
      describe ".intermediate" do
        it "returns the expected instance" do
          result = subject.intermediate
          _(result).must_be_instance_of(unit_class)
          _(result.type).must_equal("Intermediate")
        end
      end
      describe ".expert" do
        it "returns the expected instance" do
          result = subject.expert
          _(result).must_be_instance_of(unit_class)
          _(result.type).must_equal("Expert")
        end
      end

      describe ".random" do
        context "GIVEN no Patterns" do
          before do
            Pattern.delete_all
          end

          it "returns a random preset" do
            result = subject.random
            _(result).must_be_instance_of(unit_class)
            _(unit_class::PRESETS.keys).must_include(result.type)
          end
        end

        context "GIVEN Patterns exist" do
          before do
            MuchStub.(PercentChance, :call) { false }
          end

          it "sometimes returns a Pattern" do
            result = subject.random
            _(result).must_be_instance_of(unit_class)
            _(result.type).must_equal("Pattern")
            _(result.name).wont_be_nil
          end
        end
      end
    end

    describe "#validate" do
      describe "#type" do
        context "GIVEN a #type" do
          subject { unit_class.new(type: "Custom") }

          it "passes validation" do
            subject.validate
            _(subject.errors[:type]).must_be_empty
          end
        end

        context "GIVEN no #type" do
          subject { unit_class.new }

          it "fails validation" do
            subject.validate
            _(subject.errors[:type]).must_include(ValidationError.presence)
          end
        end
      end

      describe "#name" do
        subject { unit_class.new(type: "Pattern", name: name1) }

        context "GIVEN #type = Pattern" do
          context "GIVEN a #name" do
            let(:name1) { "Test" }

            it "passes validation" do
              subject.validate
              _(subject.errors[:name]).must_be_empty
            end
          end

          context "GIVEN no #name" do
            let(:name1) { nil }

            it "fails validation" do
              subject.validate
              _(subject.errors[:name]).must_include(ValidationError.presence)
            end
          end
        end

        context "GIVEN #type != Pattern" do
          subject { unit_class.new }

          it "passes validation, GIVEN no #name" do
            subject.validate
            _(subject.errors[:name]).must_be_empty
          end
        end
      end

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

    describe "#type" do
      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns the expected String" do
          _(subject.type).must_equal("Beginner")
        end
      end

      context "GIVEN custom attributes" do
        subject { unit_class[6, 6, 9] }

        describe "#type" do
          it "returns the expected String" do
            _(subject.type).must_equal("Custom")
          end
        end
      end
    end

    describe "#name" do
      subject { unit_class.beginner }

      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns nil" do
          _(subject.name).must_be_nil
        end
      end

      context "GIVEN a pattern" do
        subject { unit_class.pattern("Test Pattern 1") }

        it "returns the expected String" do
          _(subject.name).must_equal("Test Pattern 1")
        end
      end
    end

    describe "#width" do
      subject { unit_class.beginner }

      describe "#width" do
        it "returns the expected Integer" do
          _(subject.width).must_equal(9)
        end
      end
    end

    describe "#height" do
      subject { unit_class.beginner }

      it "returns the expected Integer" do
        _(subject.height).must_equal(9)
      end
    end

    describe "#mines" do
      subject { unit_class.beginner }

      it "returns the expected Integer" do
        _(subject.mines).must_equal(10)
      end
    end

    describe "#custom?" do
      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns false" do
          _(subject.custom?).must_equal(false)
        end
      end

      context "GIVEN custom attributes" do
        subject { unit_class[6, 6, 9] }

        it "returns true" do
          _(subject.custom?).must_equal(true)
        end
      end
    end

    describe "#pattern?" do
      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns false" do
          _(subject.pattern?).must_equal(false)
        end
      end

      context "GIVEN a pattern" do
        subject { unit_class.pattern("Test Pattern 1") }

        it "returns true" do
          _(subject.pattern?).must_equal(true)
        end
      end
    end

    describe "#to_s" do
      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns the expected String" do
          _(subject.to_s).must_equal("Beginner")
        end
      end

      context "GIVEN custom attributes" do
        subject { unit_class[6, 6, 9] }

        it "returns the expected String" do
          _(subject.to_s).must_equal("Custom")
        end
      end
    end

    describe "#to_h" do
      context "GIVEN a preset" do
        subject { unit_class.beginner }

        it "returns the expected Hash" do
          _(subject.to_h).must_equal(
            { type: "Beginner", width: 9, height: 9, mines: 10 })
        end
      end

      context "GIVEN custom attributes" do
        subject { unit_class[6, 6, 9] }

        describe "#to_h" do
          it "returns the expected Hash" do
            _(subject.to_h).must_equal(
              { type: "Custom", width: 6, height: 6, mines: 9 })
          end
        end
      end
    end

    describe "#as_json" do
      subject { unit_class.beginner }

      it "returns the expected Hash" do
        _(subject.as_json).must_equal(
          { type: "Beginner", width: 9, height: 9, mines: 10 })
      end
    end
  end
end
