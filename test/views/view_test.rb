# frozen_string_literal: true

require "test_helper"

class ViewTest < ActiveSupport::TestCase
  describe "View" do
    let(:unit_class) { View }

    subject { unit_class }

    describe ".dom_id" do
      it "returns the expected String" do
        _(subject.dom_id(Game.new)).must_equal("new_game")
      end
    end

    describe ".display" do
      context "GIVEN a non-blank value" do
        it "returns the result of the given block" do
          result = subject.display(12.345) { |_value| "RESULT" }
          _(result).must_equal("RESULT")
        end
      end

      context "GIVEN a blank value" do
        it "returns the expected value" do
          result = subject.display(nil) { |_value| "RESULT" }
          _(result).must_equal(%(<span class="text-dim-lg">—</span>))
        end
      end
    end

    describe ".no_value_indicator_tag" do
      it "returns the expected String" do
        _(subject.no_value_indicator_tag).must_equal(
          %(<span class="text-dim-lg">—</span>))
      end
    end

    describe ".delimit" do
      it "returns the expected String" do
        _(subject.delimit(12_345)).must_equal("12,345")
      end
    end

    describe ".round" do
      context "GIVEN the default precision" do
        it "returns the expected Float" do
          _(subject.round(12.3456789)).must_equal(12.346)
        end
      end

      context "GIVEN a precision" do
        it "returns the expected Float" do
          _(subject.round(12.3456789, precision: 1)).must_equal(12.3)
        end
      end
    end

    describe ".percentage" do
      context "GIVEN the default precision" do
        it "returns the expected String" do
          _(subject.percentage(12.345)).must_equal("12.35%")
        end
      end

      context "GIVEN a precision" do
        it "returns the expected String" do
          _(subject.percentage(12.345, precision: 1)).must_equal("12.3%")
        end
      end
    end
  end
end
