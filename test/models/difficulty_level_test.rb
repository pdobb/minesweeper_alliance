# frozen_string_literal: true

require "test_helper"

class DifficultyLevelTest < ActiveSupport::TestCase
  describe "DifficultyLevel" do
    let(:unit_class) { DifficultyLevel }

    describe "DifficultyLevel::Error" do
      subject { DifficultyLevel::Error.new }

      it "is a StandardError" do
        _(subject).must_be_kind_of(StandardError)
      end
    end

    context "Class Methods" do
      subject { unit_class }

      describe ".all" do
        it "returns an Array of instances" do
          result = subject.all
          _(result.size).must_equal(4)
          _(result.sample).must_be_instance_of(unit_class)
        end
      end

      describe ".names" do
        it "returns the expected Array" do
          _(subject.names).must_equal(%w[Test Beginner Intermediate Expert])
        end
      end

      describe ".build_random" do
        it "returns an instance" do
          _(subject.build_random).must_be_instance_of(unit_class)
        end
      end

      describe ".valid_name?" do
        it "returns true, given a valid name" do
          _(subject.valid_name?("Test")).must_equal(true)
        end

        it "returns false, given an invalid name" do
          _(subject.valid_name?("Invalid Name")).must_equal(false)
        end
      end

      describe "#initialize" do
        context "GIVEN an invalid name" do
          it "raises DifficultyLevel::Error" do
            exception =
              _(-> {
                subject.new("Invalid Name")
              }).must_raise(DifficultyLevel::Error)

            _(exception.message).must_equal(
              'got "Invalid Name", expected one of: '\
              '["Test", "Beginner", "Intermediate", "Expert"]')
          end
        end

        context "GIVEN a valid name" do
          it "returns the expected instance" do
            result = subject.new("Test")
            _(result).must_be_instance_of(unit_class)
            _(result.name).must_equal("Test")
          end
        end
      end
    end

    context "Instance Methods" do
      subject { unit_class.new("Test") }

      describe "#name" do
        it "returns the expected String" do
          _(subject.name).must_equal("Test")
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          _(subject.to_s).must_equal("Test")
        end
      end

      describe "#initials" do
        it "returns the expected String" do
          _(subject.initials).must_equal("T")
        end
      end

      describe "#dimensions" do
        it "returns the expected String" do
          _(subject.dimensions).must_equal("3x3")
        end
      end

      describe "#columns" do
        it "returns the expected Integer" do
          _(subject.columns).must_equal(3)
        end
      end

      describe "#rows" do
        it "returns the expected Integer" do
          _(subject.rows).must_equal(3)
        end
      end

      describe "#mines" do
        it "returns the expected Integer" do
          _(subject.mines).must_equal(1)
        end
      end

      describe "#settings" do
        it "returns the expected Hash" do
          _(subject.settings).must_equal({ columns: 3, rows: 3, mines: 1 })
        end
      end
    end
  end
end
