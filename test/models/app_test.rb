# frozen_string_literal: true

require "test_helper"

class AppTest < ActiveSupport::TestCase
  describe "App" do
    let(:unit_class) { App }

    subject { unit_class }

    describe ".include_test_difficulty_level?" do
      before do
        App.instance_variable_set(:@include_test_difficulty_level, nil)
      end

      after do
        App.instance_variable_set(:@include_test_difficulty_level, nil)
      end

      context "GIVEN App.test? = true" do
        before do
          MuchStub.(unit_class, :test?) { true }
        end

        context "WHETHER OR NOT any 'Test' Games exist" do
          before do
            MuchStub.tap(Game, :for_difficulty_level_test) { |arel|
              MuchStub.(arel, :any?) { [true, false].sample }
            }
          end

          it "returns true" do
            _(subject.include_test_difficulty_level?).must_equal(true)
          end
        end
      end

      context "GIVEN App.debug? = true" do
        before do
          MuchStub.(unit_class, :debug?) { true }
        end

        context "WHETHER OR NOT any 'Test' Games exist" do
          before do
            MuchStub.tap(Game, :for_difficulty_level_test) { |arel|
              MuchStub.(arel, :any?) { [true, false].sample }
            }
          end

          it "returns true" do
            _(subject.include_test_difficulty_level?).must_equal(true)
          end
        end
      end

      context "GIVEN App.test? = false and App.debug? = false" do
        before do
          MuchStub.(unit_class, :test?) { false }
          MuchStub.(unit_class, :debug?) { false }
        end

        context "GIVEN 'Test' Games do exist" do
          before do
            MuchStub.tap(Game, :for_difficulty_level_test) { |arel|
              MuchStub.(arel, :any?) { true }
            }
          end

          it "returns true" do
            _(subject.include_test_difficulty_level?).must_equal(true)
          end
        end

        context "GIVEN no 'Test' Games exist" do
          before do
            MuchStub.tap(Game, :for_difficulty_level_test) { |arel|
              MuchStub.(arel, :any?) { false }
            }
          end

          it "returns false" do
            _(subject.include_test_difficulty_level?).must_equal(false)
          end
        end

        context "GIVEN multiple calls" do
          before do
            @any_called_count = 0
            MuchStub.tap(Game, :for_difficulty_level_test) { |arel|
              MuchStub.(arel, :any?) {
                @any_called_count += 1
                false
              }
            }
          end

          it "uses a memoized result" do
            subject.include_test_difficulty_level?
            subject.include_test_difficulty_level?
            _(@any_called_count).must_equal(1)
          end
        end
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
