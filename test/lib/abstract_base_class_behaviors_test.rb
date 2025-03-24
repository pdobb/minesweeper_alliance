# frozen_string_literal: true

require "test_helper"

class AbstractBaseClassBehaviorsTest < ActiveSupport::TestCase
  let(:abstract_base_class1) {
    Class.new do
      include AbstractBaseClassBehaviors

      abstract_base_class
    end
  }
  let(:non_abstract_base_class1) {
    Class.new do
      include AbstractBaseClassBehaviors
    end
  }

  describe ".new" do
    subject { unit_class }

    given "an AbstractBassClassBehaviors" do
      subject { abstract_base_class1 }

      it "raises NotImplementedError" do
        exception =
          _(-> {
            subject.new
          }).must_raise(NotImplementedError)

        _(exception.message).must_include(
          "is an abstract base class and cannot be instantiated.")
      end
    end

    given "a non-AbstractBassClassBehaviors" do
      subject { non_abstract_base_class1 }

      it "returns the expected instance" do
        _(subject.new).must_be_instance_of(subject)
      end
    end
  end

  describe ".abstract_base_class?" do
    given "an AbstractBassClassBehaviors" do
      subject { abstract_base_class1 }

      it "returns true" do
        _(subject.abstract_base_class?).must_equal(true)
      end
    end

    given "a non-AbstractBassClassBehaviors" do
      subject { non_abstract_base_class1 }

      it "returns false" do
        _(subject.abstract_base_class?).must_equal(false)
      end
    end
  end
end
