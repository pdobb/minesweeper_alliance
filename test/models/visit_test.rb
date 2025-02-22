# frozen_string_literal: true

require "test_helper"

class VisitTest < ActiveSupport::TestCase
  describe "Visit" do
    let(:unit_class) { Visit }

    let(:visit1) { visits(:visit1) }

    describe "#validate" do
      describe "#path" do
        context "GIVEN #path == nil" do
          subject { unit_class.new }

          it "fails validation" do
            subject.validate
            _(subject.errors[:path]).must_include(ValidationError.presence)
          end
        end

        context "GIVEN #path != nil" do
          context "GIVEN #path is unique" do
            subject { unit_class.new(path: "UNIQUE NAME") }

            it "passes validation" do
              subject.validate
              _(subject.errors[:path]).must_be_empty
            end
          end

          context "GIVEN #path is not unique" do
            subject { unit_class.new(path: visit1.path) }

            it "fails validation" do
              subject.validate
              _(subject.errors[:path]).must_include(ValidationError.taken)
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
end
