# frozen_string_literal: true

require "test_helper"

class KeywordWrapTest < ActiveSupport::TestCase
  let(:object_class1) { Data.define(:name) }
  let(:object1) { object_class1["TEST_OBJECT1"] }
  let(:object2) { object_class1["TEST_OBJECT2"] }
  let(:kwargs) { { a: 1 } }

  describe ".call" do
    let(:objects) { [object1, [object2]] }
    let(:flat_objects) { objects.flatten }

    subject { KeywordWrap }

    it "returns properly wrapped objects" do
      result = subject.new(TestDouble, as: :object).call(objects, **kwargs)

      result.each_with_index do |wrapped_object, index|
        _(wrapped_object).must_be_instance_of(TestDouble)
        _(wrapped_object.object).must_be_same_as(flat_objects[index])
        _(wrapped_object.kwargs).must_equal(kwargs)
      end
    end
  end

  class TestDouble
    attr_reader :object,
                :kwargs

    def initialize(object:, **kwargs)
      @object = object
      @kwargs = kwargs
    end
  end
end
