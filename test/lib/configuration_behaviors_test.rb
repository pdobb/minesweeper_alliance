# frozen_string_literal: true

require "test_helper"

class ConfigurationBehaviorsTest < ActiveSupport::TestCase
  class ConfigurableDouble
    include ConfigurationBehaviors

    class Configuration
      attr_accessor :value1
    end
  end

  let(:unit_class) { ConfigurableDouble }

  subject { unit_class }

  describe ".configuration" do
    it "returns the expected Class" do
      _(subject.configuration).must_be_instance_of(subject::Configuration)
    end

    given "applied configuration settings" do
      before do
        subject.configure do |config|
          config.value1 = "TEST_VALUE1"
        end
      end

      it "returns the expected value" do
        _(subject.configuration.value1).must_equal("TEST_VALUE1")
      end
    end
  end
end
