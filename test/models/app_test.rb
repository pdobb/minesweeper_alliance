# frozen_string_literal: true

require "test_helper"

class AppTest < ActiveSupport::TestCase
  describe "App" do
    let(:unit_class) { App }

    subject { unit_class }

    describe ".created_at" do
      it "returns the expected Time" do
        _(unit_class.created_at.year).must_equal(2024)
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

    describe ".dev_mode?" do
      context "GIVEN Rails.configuration.dev_mode = true" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :dev_mode) { true }
          }
        end

        it "returns true" do
          _(subject.dev_mode?).must_equal(true)
        end
      end

      context "GIVEN Rails.configuration.dev_mode = false" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :dev_mode) { false }
          }
        end

        it "returns false" do
          _(subject.dev_mode?).must_equal(false)
        end
      end
    end

    describe ".disable_turbo?" do
      context "GIVEN Rails.configuration.disable_turbo = true" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :disable_turbo) { true }
          }
        end

        it "returns true" do
          _(subject.disable_turbo?).must_equal(true)
        end
      end

      context "GIVEN Rails.configuration.disable_turbo = false" do
        before do
          MuchStub.tap(Rails, :configuration) { |config|
            MuchStub.(config, :disable_turbo) { false }
          }
        end

        it "returns false" do
          _(subject.disable_turbo?).must_equal(false)
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

    describe ".production_local?" do
      context "GIVEN Rails.env.production_local? = true" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :production_local?) { true }
          }
        end

        it "returns true" do
          _(subject.production_local?).must_equal(true)
        end
      end

      context "GIVEN Rails.env.production_local? = false" do
        before do
          MuchStub.tap(Rails, :env) { |env|
            MuchStub.(env, :production_local?) { false }
          }
        end

        it "returns false" do
          _(subject.production_local?).must_equal(false)
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

    describe ".local?" do
      context "GIVEN Rails.env is a local env" do
        before { Rails.env = %w[development test production_local].sample }
        after { Rails.env = "test" }

        it "returns true" do
          _(subject.local?).must_equal(true)
        end
      end

      context "GIVEN Rails.env is not a local env" do
        before { Rails.env = "production" }
        after { Rails.env = "test" }

        it "returns false" do
          _(subject.local?).must_equal(false)
        end
      end
    end
  end
end
