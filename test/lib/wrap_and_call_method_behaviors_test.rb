# frozen_string_literal: true

require "test_helper"

class WrapAndCallMethodBehaviorsTest < ActiveSupport::TestCase
  describe "WrapAndCallMethodBehaviors" do
    let(:unit_class) {
      Class.new do
        include WrapAndCallMethodBehaviors

        attr_reader :object,
                    :object_kwargs,
                    :call_called

        def initialize(object, **object_kwargs)
          @object = object
          @object_kwargs = object_kwargs
        end

        def call = @object_kwargs.values
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

    describe "unit_class" do
      subject { unit_class }

      it "includes the expected Modules" do
        _(subject).must_include(CallMethodBehaviors)
        _(subject).must_include(WrapMethodBehaviors)
      end
    end

    describe ".wrap_and_call" do
      subject { unit_class }

      context "GIVEN a flat Array" do
        it "calls #new and #call on each object, returning the results Array" do
          results = subject.wrap_and_call(objects, **object_kwargs)
          _(results).must_equal([[1, 2], [1, 2]])
        end
      end

      context "GIVEN an Array or Arrays" do
        let(:objects) { [object1, [object2]] }

        it "calls #new and #call on each object, returning the results Array" do
          results = subject.wrap_and_call(objects, **object_kwargs)
          _(results).must_equal([[1, 2], [1, 2]])
        end
      end
    end
  end
end
