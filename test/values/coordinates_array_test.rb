# frozen_string_literal: true

require "test_helper"

class CoordinatesArrayTest < ActiveSupport::TestCase
  let(:unit_class) { CoordinatesArray }

  let(:coordinates1) { Coordinates[1, 1] }
  let(:coordinates2) { Coordinates[2, 2] }
  let(:coordinates3) { Coordinates[3, 3] }

  subject { unit_class.new([coordinates2, coordinates1]) }

  describe "#<<" do
    it "works as expected" do
      _(subject.to_a).must_equal([coordinates2, coordinates1])
      subject << coordinates3
      _(subject.to_a).must_equal([coordinates2, coordinates1, coordinates3])
    end
  end

  describe "#delete" do
    it "works as expected" do
      _(subject.to_a).must_equal([coordinates2, coordinates1])
      subject.delete(coordinates2)
      _(subject.to_a).must_equal([coordinates1])
    end
  end

  describe "#each" do
    it "works as expected" do
      _(-> { subject.each }).must_be_instance_of(Proc)
    end
  end

  describe "#include?" do
    it "works as expected" do
      _(subject.include?(coordinates1)).must_equal(true)
    end
  end

  describe "Object#in?(self)" do
    it "works as expected" do
      _(coordinates1.in?(subject)).must_equal(true)
    end
  end

  describe "#size" do
    it "works as expected" do
      _(subject.size).must_equal(2)
    end
  end

  describe "#sort!" do
    it "works as expected" do
      _(subject.to_a).must_equal([coordinates2, coordinates1])
      subject.sort!
      _(subject.to_a).must_equal([coordinates1, coordinates2])
    end
  end

  describe "#sort" do
    it "works as expected" do
      _(subject.sort).must_equal([coordinates1, coordinates2])
    end
  end

  describe "#to_a" do
    it "works as expected" do
      _(subject.to_a).must_equal([coordinates2, coordinates1])
    end
  end

  describe "#to_json" do
    it "works as expected" do
      _(subject.to_json).must_equal("[{\"x\":2,\"y\":2},{\"x\":1,\"y\":1}]")
    end
  end

  describe "#uniq!" do
    subject { unit_class.new([coordinates1, coordinates1]) }

    it "works as expected" do
      _(subject.to_a).must_equal([coordinates1, coordinates1])
      subject.uniq!
      _(subject.to_a).must_equal([coordinates1])
    end
  end

  describe "#to_ary" do
    subject { unit_class.new }

    it "returns self" do
      _(subject.to_ary).must_be_same_as(subject)
    end
  end

  describe "#<=>" do
    it "allows for sorting of Coordinates" do
      _(subject.sort.to_a).must_equal([coordinates1, coordinates2])
    end

    given "a non-Coordinates comparison object" do
      it "raises TypeError" do
        exception = _(-> { subject <=> Object.new }).must_raise(TypeError)
        _(exception.message).must_equal(
          "can't compare with non-CoordinatesArray objects, got Object")
      end
    end
  end
end
