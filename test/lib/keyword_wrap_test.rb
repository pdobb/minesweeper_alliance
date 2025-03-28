# frozen_string_literal: true

require "test_helper"

class KeywordWrapTest < ActiveSupport::TestCase
  let(:unit_class) { KeywordWrap }

  let(:wrapper_class1) {
    Class.new do
      attr_reader :object,
                  :kwargs

      def initialize(object:, **kwargs)
        @object = object
        @kwargs = kwargs
      end
    end
  }

  let(:object_class1) { Data.define(:name) }
  let(:object1) { object_class1["TEST_OBJECT1"] }
  let(:object2) { object_class1["TEST_OBJECT2"] }
  let(:kwargs) { { a: 1 } }

  describe ".call" do
    let(:objects) { [object1, [object2]] }
    let(:flat_objects) { objects.flatten }

    subject { unit_class }

    it "returns properly wrapped objects" do
      result = subject.new(wrapper_class1, as: :object).call(objects, **kwargs)

      result.each_with_index do |wrapped_object, index|
        _(wrapped_object).must_be_instance_of(wrapper_class1)
        _(wrapped_object.object).must_be_same_as(flat_objects[index])
        _(wrapped_object.kwargs).must_equal(kwargs)
      end
    end
  end
end
