# frozen_string_literal: true

require "test_helper"

class InteractionTest < ActiveSupport::TestCase
  let(:interaction1) { interactions(:interaction1) }

  describe "#validate" do
    describe "#name" do
      given "#name == nil" do
        subject { Interaction.new }

        it "fails validation" do
          subject.validate

          _(subject.errors[:name]).must_include(ValidationError.presence)
        end
      end

      given "#name != nil" do
        given "#name is unique" do
          subject { Interaction.new(name: "UNIQUE NAME") }

          it "passes validation" do
            subject.validate

            _(subject.errors[:name]).must_be_empty
          end
        end

        given "#name is not unique" do
          subject { Interaction.new(name: interaction1.name) }

          it "fails validation" do
            subject.validate

            _(subject.errors[:name]).must_include(ValidationError.taken)
          end
        end
      end
    end

    describe "#count" do
      subject { Interaction.new(count: count1) }

      given "a valid #count" do
        let(:count1) { 1 }

        it "passes validation" do
          subject.validate

          _(subject.errors[:count]).must_be_empty
        end
      end

      given "a non-numeric #count" do
        let(:count1) { "IVNALID" }

        it "fails validation" do
          subject.validate

          _(subject.errors[:count]).must_include(ValidationError.numericality)
        end
      end

      given "an invalid Integer #count" do
        let(:count1) { -1 }

        it "fails validation" do
          subject.validate

          _(subject.errors[:count]).must_include(
            ValidationError.greater_than_or_equal_to(0),
          )
        end
      end
    end
  end
end
