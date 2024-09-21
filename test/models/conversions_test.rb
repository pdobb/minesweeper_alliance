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
          _(result).must_be_same_as(instance)
        end
      end

      context "GIVEN a CustomDifficultyLevel instance" do
        subject { unit_class }

        let(:instance) {
          CustomDifficultyLevel.new(width: 9, height: 9, mines: 9)
        }

        it "returns the instance" do
          result = subject.DifficultyLevel(instance)
          _(result).must_be_same_as(instance)
        end
      end

      context "GIVEN an object that responds to :to_difficulty_level" do
        subject { unit_class }

        let(:object) {
          Class.new { def to_difficulty_level = self }.new
        }

        it "returns the object" do
          result = subject.DifficultyLevel(object)
          _(result).must_be_same_as(object)
        end
      end

      context "GIVEN a valid String" do
        subject { unit_class }

        it "returns the expected DifficultyLevel" do
          result = subject.DifficultyLevel("Test")
          _(result).must_be_instance_of(DifficultyLevel)
          _(result.name).must_equal("Test")
        end
      end

      context "GIVEN an invalid String" do
        subject { unit_class }

        it "raises DifficultyLevel::Error" do
          _(-> {
            subject.DifficultyLevel("Invalid Name")
          }).must_raise(DifficultyLevel::Error)
        end
      end
    end
  end
end
