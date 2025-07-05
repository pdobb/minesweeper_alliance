# frozen_string_literal: true

require "test_helper"

class FlatArrayTest < ActiveSupport::TestCase
  describe ".new" do
    subject { FlatArray }

    it "builds an empty FlatArray" do
      result = subject.new

      _(result).must_be_instance_of(FlatArray)
      _(result.to_a).must_equal([])
    end

    given "items" do
      it "builds a new FlatArray out of them items" do
        result = subject.new(1, [2, 3])

        _(result).must_be_instance_of(FlatArray)
        _(result.to_a).must_equal([1, 2, 3])
      end
    end
  end

  describe ".[]" do
    subject { FlatArray }

    it "builds a new FlatArray" do
      result = subject[1, [2, 3]]

      _(result).must_be_instance_of(FlatArray)
      _(result.to_a).must_equal([1, 2, 3])
    end
  end

  describe "#<<" do
    subject { FlatArray.new }

    it "flat pushes items on" do
      subject << "TEST1"
      subject << %w[TEST2 TEST3]

      _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3])
    end

    given "an Array of Arrays" do
      it "flat pushes items on" do
        subject << "TEST1"
        subject << ["TEST2", %w[TEST3 TEST4]]

        _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3 TEST4])
      end

      it "doesn't affect the original item" do
        item = ["TEST1", %w[TEST2 TEST3]]
        _(-> { subject << item }).wont_change(item)
      end
    end
  end

  describe "#push" do
    subject { FlatArray.new }

    it "flat pushes items on" do
      subject.push("TEST1")
      subject.push("TEST2", "TEST3")
      subject.push(%w[TEST4 TEST5])

      _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3 TEST4 TEST5])
    end

    given "an Array of Arrays" do
      it "flat pushes items on" do
        subject.push("TEST1")
        subject.push(["TEST2", %w[TEST3 TEST4]])

        _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3 TEST4])
      end

      it "doesn't affect the original item" do
        item = ["TEST1", %w[TEST2 TEST3]]
        _(-> { subject.push(item) }).wont_change(item)
      end
    end
  end

  describe "#concat" do
    subject { FlatArray.new }

    # rubocop:disable Style/ConcatArrayLiterals
    it "flat concatenates items on" do
      subject.concat("TEST1")
      subject.concat(%w[TEST2 TEST3])

      _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3])
    end

    given "an Array of Arrays" do
      it "flat concatenates items on" do
        subject.concat("TEST1")
        subject.concat(["TEST2", %w[TEST3 TEST4]])

        _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3 TEST4])
      end

      it "doesn't affect the original item" do
        item = ["TEST1", %w[TEST2 TEST3]]
        _(-> { subject.concat(item) }).wont_change(item)
      end
    end
    # rubocop:enable Style/ConcatArrayLiterals
  end

  describe "[<FlatArray>]#flatten" do
    subject { FlatArray[4, 5, 6] }

    it "splats itself as needed" do
      result = [1, 2, 3, subject].flatten

      _(result).must_equal([1, 2, 3, 4, 5, 6])
    end
  end

  describe "#sort" do
    subject { FlatArray.new([3, 1, [4, 2]]) }

    it "returns a sorted FlatArray" do
      result = subject.sort

      _(result).must_be_instance_of(FlatArray)
      _(result.to_a).must_equal([1, 2, 3, 4])
    end
  end
end
