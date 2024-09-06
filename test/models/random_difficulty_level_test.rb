# frozen_string_literal: true

require "test_helper"

class RandomDifficultyLevelTest < ActiveSupport::TestCase
  describe "RandomDifficultyLevel" do
    let(:unit_class) { RandomDifficultyLevel }

    context "Class Methods" do
      subject { unit_class }

      describe "#initialize" do
        it "returns a frozen RandomDifficultyLevel instance" do
          result = subject.new
          _(result).must_be_instance_of(unit_class)
          _(result.frozen?).must_equal(true)
        end
      end
    end

    context "Instance Methods" do
      subject { unit_class.new }

      describe "#name" do
        it "returns the expected String" do
          _(subject.name).must_equal("Random")
        end
      end
    end
  end
end
