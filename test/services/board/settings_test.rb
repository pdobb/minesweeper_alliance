# frozen_string_literal: true

require "test_helper"

class Board::SettingsTest < ActiveSupport::TestCase
  context "Class Methods" do
    subject { Board::Settings }

    describe ".preset" do
      given "a valid type" do
        let(:type1) { ["Beginner", "intermediate", :expert].sample }

        it "returns the expected instance" do
          result = subject.preset(type1)
          _(result).must_be_instance_of(Board::Settings)
          _(Board::Settings::PRESETS.keys).must_include(result.type)
        end
      end

      given "an unknown type" do
        it "raises KeyError" do
          exception = _(-> { subject.preset("UNKNOWN") }).must_raise(KeyError)
          _(exception.message).must_equal('key not found: "Unknown"')
        end
      end

      given "type = nil" do
        it "raises TypeError" do
          exception = _(-> { subject.preset(nil) }).must_raise(TypeError)
          _(exception.message).must_equal("type can't be blank")
        end
      end
    end

    describe ".beginner" do
      it "returns the expected instance" do
        result = subject.beginner
        _(result).must_be_instance_of(Board::Settings)
        _(result.type).must_equal("Beginner")
      end
    end
    describe ".intermediate" do
      it "returns the expected instance" do
        result = subject.intermediate
        _(result).must_be_instance_of(Board::Settings)
        _(result.type).must_equal("Intermediate")
      end
    end
    describe ".expert" do
      it "returns the expected instance" do
        result = subject.expert
        _(result).must_be_instance_of(Board::Settings)
        _(result.type).must_equal("Expert")
      end
    end

    describe ".random" do
      given "no Patterns" do
        before do
          Pattern.delete_all
        end

        it "returns a random preset" do
          result = subject.random
          _(result).must_be_instance_of(Board::Settings)
          _(Board::Settings::PRESETS.keys).must_include(result.type)
        end
      end

      given "Patterns exist" do
        given "PercentChange.call returns true" do
          before do
            MuchStub.(PercentChance, :call) { true }
          end

          it "returns a random Preset Type" do
            result = subject.random
            _(result).must_be_instance_of(Board::Settings)
            _(result.type).wont_equal("Pattern")
            _(result.name).must_be_nil
          end
        end

        given "PercentChange.call returns false" do
          before do
            MuchStub.(PercentChance, :call) { false }
          end

          it "returns a random Pattern Type" do
            result = subject.random
            _(result).must_be_instance_of(Board::Settings)
            _(result.type).must_equal("Pattern")
            _(result.name).wont_be_nil
          end
        end
      end
    end
  end

  describe "#validate" do
    describe "#type" do
      given "a #type" do
        subject { Board::Settings.new(type: "Custom") }

        it "passes validation" do
          subject.validate
          _(subject.errors[:type]).must_be_empty
        end
      end

      given "no #type" do
        subject { Board::Settings.new }

        it "fails validation" do
          subject.validate
          _(subject.errors[:type]).must_include(ValidationError.presence)
        end
      end
    end

    describe "#name" do
      subject { Board::Settings.new(type: "Pattern", name: name1) }

      given "#type = Pattern" do
        given "a #name" do
          let(:name1) { "Test" }

          it "passes validation" do
            subject.validate
            _(subject.errors[:name]).must_be_empty
          end
        end

        given "no #name" do
          let(:name1) { nil }

          it "fails validation" do
            subject.validate
            _(subject.errors[:name]).must_include(ValidationError.presence)
          end
        end
      end

      given "#type != Pattern" do
        subject { Board::Settings.new }

        it "passes validation, GIVEN no #name" do
          subject.validate
          _(subject.errors[:name]).must_be_empty
        end
      end
    end

    describe "#width" do
      subject { Board::Settings[width1, 9, 4] }

      given "a valid #width" do
        let(:width1) { 9 }

        it "passes validation" do
          subject.validate
          _(subject.errors[:width]).must_be_empty
        end
      end

      given "#width is not in the expected range" do
        let(:width1) { [2, 31].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:width]).must_include(ValidationError.in(6..30))
        end
      end

      given "#width is nil" do
        let(:width1) { nil }

        it "fails validation" do
          subject.validate
          _(subject.errors[:width]).must_include(ValidationError.presence)
        end
      end
    end

    describe "#height" do
      subject { Board::Settings[9, height1, 4] }

      given "a valid #height" do
        let(:height1) { 9 }

        it "passes validation" do
          subject.validate
          _(subject.errors[:height]).must_be_empty
        end
      end

      given "#height is not in the expected range" do
        let(:height1) { [2, 31].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:height]).must_include(ValidationError.in(6..30))
        end
      end

      given "#height is nil" do
        let(:height1) { nil }

        it "fails validation" do
          subject.validate
          _(subject.errors[:height]).must_include(ValidationError.presence)
        end
      end
    end

    describe "#dimensions" do
      subject { Board::Settings[9, 9, 4] }

      it "returns the expectd value" do
        _(subject.dimensions).must_equal("9x9")
      end
    end

    describe "#mines" do
      subject { Board::Settings[9, 9, mines1] }

      given "a valid #mines" do
        let(:mines1) { 10 }

        it "passes validation" do
          subject.validate
          _(subject.errors[:mines]).must_be_empty
        end
      end

      given "#mines is not in expected range" do
        let(:mines1) { [3, 300].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:mines]).must_include(ValidationError.in(4..299))
        end
      end

      given "#mines is nil" do
        let(:mines1) { nil }

        it "fails validation" do
          subject.validate
          _(subject.errors[:mines]).must_include(ValidationError.presence)
        end
      end

      given "other validation errors present" do
        subject { Board::Settings[-1, 9, mines1] }

        given "too many #mines" do
          let(:mines1) { 99 }

          it "fails validation, but not due to density" do
            subject.validate
            _(subject.errors[:mines]).wont_include(
              "must be <= 12 (1/3 of total area)")
          end
        end

        given "too few #mines" do
          let(:mines1) { 3 }

          it "fails validation, but not due to sparseness" do
            subject.validate
            _(subject.errors[:mines]).wont_include(
              "must be >= 9 (10% of total area)")
          end
        end
      end

      given "no other validation errors present" do
        subject { Board::Settings[9, 9, mines1] }

        given "too many #mines" do
          let(:mines1) { 99 }

          it "fails validation" do
            subject.validate
            _(subject.errors[:mines]).must_include(
              "must be <= 27 (1/3 of total area)")
          end
        end

        given "too few #mines" do
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
    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns the expected String" do
        _(subject.type).must_equal("Beginner")
      end
    end

    given "custom attributes" do
      subject { Board::Settings[6, 6, 9] }

      describe "#type" do
        it "returns the expected String" do
          _(subject.type).must_equal("Custom")
        end
      end
    end
  end

  describe "#name" do
    subject { Board::Settings.beginner }

    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns nil" do
        _(subject.name).must_be_nil
      end
    end

    given "a pattern" do
      subject { Board::Settings.pattern("Test Pattern 1") }

      it "returns the expected String" do
        _(subject.name).must_equal("Test Pattern 1")
      end
    end
  end

  describe "#width" do
    subject { Board::Settings.beginner }

    describe "#width" do
      it "returns the expected Integer" do
        _(subject.width).must_equal(9)
      end
    end
  end

  describe "#height" do
    subject { Board::Settings.beginner }

    it "returns the expected Integer" do
      _(subject.height).must_equal(9)
    end
  end

  describe "#mines" do
    subject { Board::Settings.beginner }

    it "returns the expected Integer" do
      _(subject.mines).must_equal(10)
    end
  end

  describe "#custom?" do
    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns false" do
        _(subject.custom?).must_equal(false)
      end
    end

    given "custom attributes" do
      subject { Board::Settings[6, 6, 9] }

      it "returns true" do
        _(subject.custom?).must_equal(true)
      end
    end
  end

  describe "#pattern?" do
    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns false" do
        _(subject.pattern?).must_equal(false)
      end
    end

    given "a pattern" do
      subject { Board::Settings.pattern("Test Pattern 1") }

      it "returns true" do
        _(subject.pattern?).must_equal(true)
      end
    end
  end

  describe "#to_s" do
    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns the expected String" do
        _(subject.to_s).must_equal("Beginner")
      end
    end

    given "custom attributes" do
      subject { Board::Settings[6, 6, 9] }

      it "returns the expected String" do
        _(subject.to_s).must_equal("Custom")
      end
    end
  end

  describe "#to_h" do
    given "a preset" do
      subject { Board::Settings.beginner }

      it "returns the expected Hash" do
        _(subject.to_h).must_equal(
          { type: "Beginner", width: 9, height: 9, mines: 10 })
      end
    end

    given "custom attributes" do
      subject { Board::Settings[6, 6, 9] }

      describe "#to_h" do
        it "returns the expected Hash" do
          _(subject.to_h).must_equal(
            { type: "Custom", width: 6, height: 6, mines: 9 })
        end
      end
    end
  end

  describe "#as_json" do
    subject { Board::Settings.beginner }

    it "returns the expected Hash" do
      _(subject.as_json).must_equal(
        { type: "Beginner", width: 9, height: 9, mines: 10 })
    end
  end
end
