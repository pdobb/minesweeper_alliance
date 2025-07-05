# frozen_string_literal: true

require "test_helper"

class CompactArrayTest < ActiveSupport::TestCase
  describe ".new" do
    subject { CompactArray }

    it "builds an empty CompactArray" do
      result = subject.new

      _(result).must_be_instance_of(CompactArray)
      _(result.to_a).must_equal([])
    end

    given "items" do
      it "builds a new CompactArray out of them items" do
        result = subject.new(1, 2, nil, 3)

        _(result).must_be_instance_of(CompactArray)
        _(result.to_a).must_equal([1, 2, 3])
      end
    end
  end

  describe ".[]" do
    subject { CompactArray }

    it "builds a new CompactArray" do
      result = subject[1, 2, nil, 3]

      _(result).must_be_instance_of(CompactArray)
      _(result.to_a).must_equal([1, 2, 3])
    end
  end

  describe "#<<" do
    subject { CompactArray.new }

    it "compact pushes items on" do
      subject << nil
      subject << "TEST1"
      subject << false

      _(subject.to_a).must_equal(["TEST1", false])
    end
  end

  describe "#push" do
    subject { CompactArray.new }

    it "compact pushes items on" do
      subject.push(nil)
      subject.push("TEST1")
      subject.push(false, nil)

      _(subject.to_a).must_equal(["TEST1", false])
    end
  end

  describe "[<CompactArray>]#flatten" do
    subject { CompactArray[4, 5, 6] }

    it "splats itself as needed" do
      result = [1, 2, 3, subject].flatten

      _(result).must_equal([1, 2, 3, 4, 5, 6])
    end
  end

  describe "#sort" do
    subject { CompactArray.new(2, nil, 1) }

    it "returns a sorted CompactArray" do
      result = subject.sort

      _(result).must_be_instance_of(CompactArray)
      _(result.to_a).must_equal([1, 2])
    end
  end
end
