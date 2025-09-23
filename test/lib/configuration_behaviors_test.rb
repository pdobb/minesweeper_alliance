# frozen_string_literal: true

require "test_helper"

class ConfigurationBehaviorsTest < ActiveSupport::TestCase
  describe ".configure" do
    subject { ConfigurableTestDouble }

    it "yields the expected Configuration object to the block" do
      subject.configure do |config|
        _(config).must_equal(subject.configuration)
      end
    end

    it "returns the expected Configuration object" do
      _(subject.configure).must_equal(subject.configuration)
    end
  end

  describe ".configuration" do
    subject { ConfigurableTestDouble }

    it "returns the expected object type" do
      _(subject.configuration).must_be_instance_of(subject::Configuration)
    end

    it "returns the exact same object (by identify), each time" do
      _(subject.configuration.object_id).must_equal(
        subject.configuration.object_id,
      )
    end
  end

  class ConfigurableTestDouble
    Configuration = Class.new
    public_constant :Configuration

    include ConfigurationBehaviors
  end
end
