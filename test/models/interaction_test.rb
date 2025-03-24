# frozen_string_literal: true

require "test_helper"

class InteractionTest < ActiveSupport::TestCase
  let(:unit_class) { Interaction }

  let(:interaction1) { interactions(:interaction1) }

  describe "#validate" do
    describe "#name" do
      context "GIVEN #name == nil" do
        subject { unit_class.new }

        it "fails validation" do
          subject.validate
          _(subject.errors[:name]).must_include(ValidationError.presence)
        end
      end

      context "GIVEN #name != nil" do
        context "GIVEN #name is unique" do
          subject { unit_class.new(name: "UNIQUE NAME") }

          it "passes validation" do
            subject.validate
            _(subject.errors[:name]).must_be_empty
          end
        end

        context "GIVEN #name is not unique" do
          subject { unit_class.new(name: interaction1.name) }

          it "fails validation" do
            subject.validate
            _(subject.errors[:name]).must_include(ValidationError.taken)
          end
        end
      end
    end

    describe "#count" do
      subject { unit_class.new(count: count1) }

      context "GIVEN a valid #count" do
        let(:count1) { 1 }

        it "passes validation" do
          subject.validate
          _(subject.errors[:count]).must_be_empty
        end
      end

      context "GIVEN a non-numeric #count" do
        let(:count1) { "IVNALID" }

        it "fails validation" do
          subject.validate
          _(subject.errors[:count]).must_include(ValidationError.numericality)
        end
      end

      context "GIVEN an invalid Integer #count" do
        let(:count1) { -1 }

        it "fails validation" do
          subject.validate
          _(subject.errors[:count]).must_include(
            ValidationError.greater_than_or_equal_to(0))
        end
      end
    end
  end
end
