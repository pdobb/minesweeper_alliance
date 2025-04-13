# frozen_string_literal: true

require "test_helper"

class VisitTest < ActiveSupport::TestCase
  let(:visit1) { visits(:visit1) }

  describe "#validate" do
    describe "#path" do
      given "#path == nil" do
        subject { Visit.new }

        it "fails validation" do
          subject.validate
          _(subject.errors[:path]).must_include(ValidationError.presence)
        end
      end

      given "#path != nil" do
        given "#path is unique" do
          subject { Visit.new(path: "UNIQUE NAME") }

          it "passes validation" do
            subject.validate
            _(subject.errors[:path]).must_be_empty
          end
        end

        given "#path is not unique" do
          subject { Visit.new(path: visit1.path) }

          it "fails validation" do
            subject.validate
            _(subject.errors[:path]).must_include(ValidationError.taken)
          end
        end
      end
    end

    describe "#count" do
      subject { Visit.new(count: count1) }

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
            ValidationError.greater_than_or_equal_to(0))
        end
      end
    end
  end
end
