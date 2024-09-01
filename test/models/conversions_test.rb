# frozen_string_literal: true

require "test_helper"

class ConversionsTest < ActiveSupport::TestCase
  describe "Conversions" do
    let(:unit_class) { Conversions }

    describe ".DifficultyLevel" do
      context "GIVEN a DifficultyLevel instance" do
        subject { unit_class }

        let(:instance) { DifficultyLevel.new("Test") }

        it "returns the instance" do
          result = subject.DifficultyLevel(instance)
          value(result).must_be_same_as(instance)
        end
      end

      context "GIVEN an object that responds to :to_difficulty_level" do
        subject { unit_class }

        let(:object) { DifficultyLevelable.new }

        it "returns the object" do
          result = subject.DifficultyLevel(object)
          value(result).must_be_same_as(object)
        end
      end

      context "GIVEN 'Random'" do
        subject { unit_class }

        it "returns the expected DifficultyLevel" do
          result = subject.DifficultyLevel("Random")
          value(result).must_be_instance_of(DifficultyLevel)
          value(result.name).must_be(
            :in?, %w[Test Beginner Intermediate Expert])
        end
      end

      context "GIVEN a valid String" do
        subject { unit_class }

        it "returns the expected DifficultyLevel" do
          result = subject.DifficultyLevel("Test")
          value(result).must_be_instance_of(DifficultyLevel)
          value(result.name).must_equal("Test")
        end
      end

      context "GIVEN an invalid String" do
        subject { unit_class }

        it "raises DifficultyLevel::Error" do
          value(-> {
            subject.DifficultyLevel("Invalid Name")
          }).must_raise(DifficultyLevel::Error)
        end
      end
    end
  end

  class DifficultyLevelable
    def to_difficulty_level = self
  end
end
