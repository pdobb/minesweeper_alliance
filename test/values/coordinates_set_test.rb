# frozen_string_literal: true

require "test_helper"

class CoordinatesSetTest < ActiveSupport::TestCase
  let(:coordinates1) { Coordinates[1, 1] }
  let(:coordinates2) { Coordinates[2, 2] }
  let(:coordinates3) { Coordinates[3, 3] }

  describe "#<<" do
    subject { CoordinatesSet.new(coordinates1) }

    it "adds the given Coordinates" do
      _(-> { subject.add(coordinates3) }).must_change(
        "subject.include?(coordinates3)", to: true)
    end
  end

  describe "#add" do
    subject { CoordinatesSet.new(coordinates1) }

    it "adds the given Coordinates" do
      _(-> { subject.add(coordinates3) }).must_change(
        "subject.include?(coordinates3)", to: true)
    end
  end

  describe "#delete" do
    subject { CoordinatesSet.new(coordinates1) }

    it "works as expected" do
      _(-> { subject.delete(coordinates1) }).must_change(
        "subject.include?(coordinates1)", to: false)
    end
  end

  describe "#each" do
    subject { CoordinatesSet.new([coordinates2, coordinates1]) }

    it "returns a Proc" do
      _(-> { subject.each }).must_be_instance_of(Proc)
    end
  end

  describe "#include?" do
    subject { CoordinatesSet.new(coordinates1) }

    given "coordinates_set.include? == true" do
      it "returns true" do
        _(subject.include?(coordinates1)).must_equal(true)
      end
    end

    given "coordinates_set.include? == false" do
      it "returns false" do
        _(subject.include?(coordinates3)).must_equal(false)
      end
    end
  end

  describe "Object#in?(self)" do
    subject { CoordinatesSet.new(coordinates1) }

    given "coordinates_set.include? == true" do
      it "returns true" do
        _(coordinates1.in?(subject)).must_equal(true)
      end
    end

    given "coordinates_set.include? == false" do
      it "returns false" do
        _(coordinates3.in?(subject)).must_equal(false)
      end
    end
  end

  describe "#size" do
    subject { CoordinatesSet.new(coordinates1) }

    it "returns the execpted Integer" do
      _(subject.size).must_equal(1)
    end
  end

  describe "#sort" do
    subject { CoordinatesSet.new([coordinates2, coordinates1]) }

    it "returns a sorted Array" do
      _(subject.sort).must_equal([coordinates1, coordinates2])
    end
  end

  describe "#to_a" do
    subject { CoordinatesSet.new([coordinates1, coordinates2]) }

    it "returns the expected Array" do
      _(subject.to_a).must_equal([coordinates1, coordinates2])
    end
  end

  describe "#to_json" do
    subject { CoordinatesSet.new([coordinates1, coordinates2]) }

    it "works as expected" do
      _(subject.to_json).must_equal("[{\"x\":1,\"y\":1},{\"x\":2,\"y\":2}]")
    end
  end

  describe "#<=>" do
    subject { CoordinatesSet.new([coordinates2, coordinates1]) }

    it "allows for sorting of Coordinates" do
      _(subject.sort).must_match_array([coordinates1, coordinates2])
    end

    given "a non-Coordinates comparison object" do
      it "raises TypeError" do
        exception = _(-> { subject <=> Object.new }).must_raise(TypeError)
        _(exception.message).must_equal(
          "Can't convert unexpected type to CoordinatesSet, got Object")
      end
    end
  end

  describe "#toggle" do
    subject { CoordinatesSet.new([coordinates2, coordinates1]) }

    given "coordinates_set.include? == true" do
      it "removes the Coordinates" do
        _(-> { subject.toggle(coordinates2) }).must_change(
          "subject.include?(coordinates2)", to: false)
      end
    end

    given "coordinates_set.include? == false" do
      it "adds the Coordinates" do
        _(-> { subject.toggle(coordinates3) }).must_change(
          "subject.include?(coordinates3)", to: true)
      end
    end
  end
end
