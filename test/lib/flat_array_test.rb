# frozen_string_literal: true

require "test_helper"

class FlatArrayTest < ActiveSupport::TestCase
  describe "FlatArray" do
    let(:unit_class) { FlatArray }

    describe ".new" do
      subject { unit_class }

      it "builds an empty FlatArray" do
        result = subject.new
        _(result.to_a).must_equal([])
      end

      context "GIVEN items" do
        it "builds a new FlatArray out of them items" do
          result = subject.new(1, 2, 3)
          _(result.to_a).must_equal([1, 2, 3])
        end
      end
    end

    describe ".[]" do
      subject { unit_class }

      it "builds a new FlatArray" do
        result = subject[1, 2, 3]
        _(result.to_a).must_equal([1, 2, 3])
      end
    end

    describe "#<<" do
      subject { unit_class.new }

      it "flat pushes items on" do
        subject << "TEST1"
        subject << %w[TEST2 TEST3]
        _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3])
      end
    end

    describe "#push" do
      subject { unit_class.new }

      it "flat pushes items on" do
        subject.push("TEST1")
        subject.push(%w[TEST2 TEST3])
        _(subject.to_a).must_equal(%w[TEST1 TEST2 TEST3])
      end
    end

    describe "[<FlatArray>]#flatten" do
      subject { unit_class[4, 5, 6] }

      it "splats itself as needed" do
        result = [1, 2, 3, subject].flatten
        _(result).must_equal([1, 2, 3, 4, 5, 6])
      end
    end
  end
end
