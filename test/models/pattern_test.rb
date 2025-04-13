# frozen_string_literal: true

require "test_helper"

class PatternTest < ActiveSupport::TestCase
  let(:pattern1) { patterns(:pattern1) }
  let(:coordinates_array1) { [Coordinates[0, 0], Coordinates[1, 1]] }

  describe "#validate" do
    describe "#name" do
      given "#name == nil" do
        subject { Pattern.new }

        it "fails validation" do
          subject.validate
          _(subject.errors[:name]).must_include(ValidationError.presence)
        end
      end

      given "#name != nil" do
        given "#name is unique" do
          subject { Pattern.new(name: "UNIQUE NAME") }

          it "passes validation" do
            subject.validate
            _(subject.errors[:name]).must_be_empty
          end
        end

        given "#name is not unique" do
          subject { Pattern.new(name: pattern1.name) }

          it "fails validation" do
            subject.validate
            _(subject.errors[:name]).must_include(ValidationError.taken)
          end
        end
      end
    end

    describe "#settings" do
      given "#settings != nil" do
        subject { Pattern.new(settings: { width: 9, height: 9 }) }

        it "passes validation" do
          subject.validate
          _(subject.errors[:settings]).must_be_empty
        end
      end

      given "#settings that are invalid, per Pattern::Settings" do
        subject { Pattern.new(settings: { width: 0 }) }

        it "fails validation" do
          subject.validate
          _(subject.errors[:width]).must_include(ValidationError.in(6..30))
        end
      end
    end
  end

  describe "#coordinates_array" do
    subject { Pattern.new(coordinates_array: [Coordinates[9, 9]]) }

    it "returns the expected CoordinatesArray" do
      result = subject.coordinates_array
      _(result).must_be_instance_of(CoordinatesArray)
      _(result.to_a).must_equal([Coordinates[9, 9]])
    end
  end

  describe "#settings" do
    subject { Pattern.new }

    it "returns a Pattern::Settings" do
      _(subject.settings).must_be_instance_of(Pattern::Settings)
    end

    it "defaults to 6x6" do
      _(subject.settings.to_h).must_equal({ width: 6, height: 6 })
    end
  end

  describe "#width" do
    subject { Pattern.new }

    it "returns the expected Integer" do
      _(subject.width).must_equal(6)
    end
  end

  describe "#height" do
    subject { Pattern.new }

    it "returns the expected Integer" do
      _(subject.height).must_equal(6)
    end
  end

  describe "#cells_count" do
    subject { Pattern.new }

    it "returns the expected Integer" do
      _(subject.cells_count).must_equal(36)
    end
  end

  describe "#dimensions" do
    subject { Pattern.new }

    it "returns the expected Integer" do
      _(subject.dimensions).must_equal("6x6")
    end
  end

  describe "#grid" do
    subject { Pattern.new }

    it "returns a Grid with Pattern::Cells" do
      result = subject.grid
      _(result).must_be_instance_of(Grid)
      _(result.cells_count).must_equal(36)
      _(result.to_a.flatten!.sample).must_be_instance_of(Pattern::Cell)
    end
  end

  describe "#cells" do
    subject { Pattern.new }

    it "returns the expected Array" do
      result = subject.cells
      _(result).must_be_instance_of(Array)
      _(result.size).must_equal(36)
      _(result.sample).must_be_instance_of(Pattern::Cell)
    end
  end

  describe "#flag_density" do
    given "no flags" do
      subject { Pattern.new }

      it "returns the expected Float" do
        _(subject.flag_density).must_equal(0.0)
      end
    end

    given "flags" do
      subject { Pattern.new(coordinates_array: coordinates_array1) }

      it "returns the expected Float" do
        _(subject.flag_density).must_be_close_to(0.05555555555555555)
      end
    end
  end

  describe "#flags_count" do
    given "no flags" do
      subject { Pattern.new }

      it "returns the expected Integer" do
        _(subject.flags_count).must_equal(0)
      end
    end

    given "flags" do
      subject { Pattern.new(coordinates_array: coordinates_array1) }

      it "returns the expected Integer" do
        _(subject.flags_count).must_equal(2)
      end
    end
  end

  describe "#mines" do
    given "no flags" do
      subject { Pattern.new }

      it "returns the expected Integer" do
        _(subject.mines).must_equal(0)
      end
    end

    given "flags" do
      subject { Pattern.new(coordinates_array: coordinates_array1) }

      it "returns the expected Integer" do
        _(subject.mines).must_equal(2)
      end
    end
  end

  describe "#flagged?" do
    subject { Pattern.new(coordinates_array: coordinates_array1) }

    given "an included Coordinates" do
      it "returns true" do
        _(subject.flagged?(Coordinates[0, 0])).must_equal(true)
      end
    end

    given "an excluded Coordinates" do
      it "returns false" do
        _(subject.flagged?(Coordinates[9, 9])).must_equal(false)
      end
    end
  end

  describe "#reset" do
    subject { pattern1 }

    it "empties out #coordinate_array" do
      _(-> { subject.reset }).must_change(
        "subject.coordinates_array.to_a", to: [])
    end
  end
end
