# frozen_string_literal: true

require "test_helper"

class CallMethodBehaviorsTest < ActiveSupport::TestCase
  describe "CallMethodBehaviors" do
    let(:unit_class) {
      Class.new do
        include CallMethodBehaviors
      end
    }

    describe ".call" do
      before do
        MuchStub.tap(subject, :new) { |new_record|
          @new_class_method_called = true

          MuchStub.(new_record, :call) {
            @call_instance_method_called = true
          }
        }
      end

      subject { unit_class }

      it "calls #new and #call" do
        subject.call

        _(@new_class_method_called).must_equal(true)
        _(@call_instance_method_called).must_equal(true)
      end
    end

    describe "#call" do
      subject { unit_class.new }

      it "raises NotImplementedError" do
        _(-> { subject.call }).must_raise(NotImplementedError)
      end
    end
  end
end
