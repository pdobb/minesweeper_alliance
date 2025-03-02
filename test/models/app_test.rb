# frozen_string_literal: true

require "test_helper"

class AppTest < ActiveSupport::TestCase
  describe "App" do
    let(:unit_class) { App }

    subject { unit_class }

    describe ".created_at" do
      it "returns the expected Time" do
        result = unit_class.created_at
        _(result.year).must_equal(2024)
        _(result.month).must_equal(8)
        _(result.day).must_equal(9)
      end
    end

    describe ".debug?" do
      context "GIVEN Rails.configuration.debug = true" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :debug) { true }
          }
        end

        it "returns true" do
          _(subject.debug?).must_equal(true)
        end
      end

      context "GIVEN Rails.configuration.debug = false" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :debug) { false }
          }
        end

        it "returns false" do
          _(subject.debug?).must_equal(false)
        end
      end
    end

    describe ".development?" do
      context "GIVEN Rails.env.development? = true" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :development?) { true }
          }
        end

        it "returns true" do
          _(subject.development?).must_equal(true)
        end
      end

      context "GIVEN Rails.env.development? = false" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :development?) { false }
          }
        end

        it "returns false" do
          _(subject.development?).must_equal(false)
        end
      end
    end

    describe ".production?" do
      context "GIVEN Rails.env.production? = true" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :production?) { true }
          }
        end

        it "returns true" do
          _(subject.production?).must_equal(true)
        end
      end

      context "GIVEN Rails.env.production? = false" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :production?) { false }
          }
        end

        it "returns false" do
          _(subject.production?).must_equal(false)
        end
      end
    end
  end
end
