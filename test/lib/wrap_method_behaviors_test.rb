# frozen_string_literal: true

require "test_helper"

class WrapMethodBehaviorsTest < ActiveSupport::TestCase
  describe "WrapMethodBehaviors" do
    let(:unit_class1) {
      Class.new do
        include WrapMethodBehaviors

        attr_reader :object,
                    :object_kwargs

        def initialize(object, **object_kwargs)
          @object = object
          @object_kwargs = object_kwargs
        end
      end
    }
    let(:unit_class2) {
      Class.new do
        include WrapMethodBehaviors

        attr_reader :key,
                    :value,
                    :object_kwargs

        def initialize(key, value, **object_kwargs)
          @key = key
          @value = value
          @object_kwargs = object_kwargs
        end
      end
    }

    let(:objects) { [object1, object2] }
    let(:object1) { Data.define(:name).new("TEST_OBJECT1") }
    let(:object2) { Data.define(:name).new("TEST_OBJECT2") }

    let(:object_kwargs) {
      {
        test_key1: 1,
        test_key2: 2,
      }
    }

    describe ".wrap" do
      subject { unit_class1 }

      it "calls #new on each object" do
        wrapped_objects = subject.wrap(objects, **object_kwargs)

        _(wrapped_objects.size).must_equal(objects.size)
        wrapped_objects.each_with_index do |wrapped_object, index|
          _(wrapped_object).must_be_instance_of(subject)
          _(wrapped_object.object).must_equal(objects[index])
          _(wrapped_object.object_kwargs).must_equal(object_kwargs)
        end
      end

      context "GIVEN a non-flat Array" do
        let(:objects) { [object1, [object2]] }

        it "flattens the Array and calls #new on each object" do
          wrapped_objects = subject.wrap(objects, **object_kwargs)

          _(wrapped_objects.size).must_equal(objects.size)
          wrapped_objects.each_with_index do |wrapped_object, index|
            _(wrapped_object).must_be_instance_of(subject)
            _(wrapped_object.object).must_equal(objects.flatten[index])
            _(wrapped_object.object_kwargs).must_equal(object_kwargs)
          end
        end
      end
    end

    describe ".wrap_hash" do
      let(:hash1) {
        { "key1" => objects, "key2" => objects }
      }

      subject { unit_class2 }

      it "calls #new on each object" do
        result = subject.wrap_hash(hash1, **object_kwargs)

        _(result.size).must_equal(objects.size)
        result.each_with_index do |wrapped_object, index|
          _(wrapped_object).must_be_instance_of(subject)
          _(wrapped_object.key).must_equal(hash1.keys[index])
          _(wrapped_object.value).must_equal(hash1.values[index])
          _(wrapped_object.object_kwargs).must_equal(object_kwargs)
        end
      end
    end

    describe ".wrap_upto" do
      subject { unit_class1 }

      context "GIVEN limit < objects.size" do
        let(:limit) { 1 }

        it "wraps and returns the objects, up to limit" do
          wrapped_objects = subject.wrap_upto(objects, limit:, **object_kwargs)

          _(wrapped_objects.size).must_equal(limit)
          wrapped_objects.each_with_index do |wrapped_object, index|
            _(wrapped_object).must_be_instance_of(subject)
            _(wrapped_object.object).must_equal(objects[index])
            _(wrapped_object.object_kwargs).must_equal(object_kwargs)
          end
        end
      end

      context "GIVEN limit > objects.size" do
        let(:limit) { 3 }

        it "wraps/returns the objects, filled with `nil`s up to the limit" do
          wrapped_objects = subject.wrap_upto(objects, limit:, **object_kwargs)

          _(wrapped_objects.size).must_equal(limit)
          _(wrapped_objects[limit.pred]).must_be_nil
        end

        context "GIVEN a fill object" do
          it "wraps/returns the objects, filled with the given fill object, "\
             "up to the limit" do
            wrapped_objects =
              subject.wrap_upto(
                objects, limit:, fill: "FILL_OBJECT_TEST", **object_kwargs)

            _(wrapped_objects.size).must_equal(limit)
            _(wrapped_objects[limit.pred]).must_equal("FILL_OBJECT_TEST")
          end
        end

        context "GIVEN a non-flat Array" do
          let(:objects) { [object1, [object2]] }

          it "wraps/returns the objects, filled with `nil`s up to the limit" do
            wrapped_objects =
              subject.wrap_upto(objects, limit:, **object_kwargs)

            _(wrapped_objects.size).must_equal(limit)
            _(wrapped_objects[limit.pred]).must_be_nil
          end
        end
      end
    end
  end
end
