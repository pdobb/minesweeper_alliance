# frozen_string_literal: true

require "test_helper"

class DutyRosterTest < ActiveSupport::TestCase
  describe "DutyRoster" do
    let(:unit_class) { DutyRoster }

    describe ".count" do
      subject { unit_class }

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns 0" do
          _(subject.count).must_equal(0)
        end
      end

      context "GIVEN a cache hit" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new(9) } }

        it "returns the expected Integer" do
          _(subject.count).must_equal(9)
        end
      end
    end

    describe ".increment" do
      before do
        @broadcast_refresh_to_called_count = 0
        MuchStub.on_call(Turbo::StreamsChannel, :broadcast_refresh_to) { |call|
          @broadcast_refresh_to_call = call
          @broadcast_refresh_to_called_count += 1
        }
      end

      subject { unit_class }

      it "calls Turbo::StreamsChannel.broadcasts_refresh_to" do
        subject.increment
        _(@broadcast_refresh_to_called_count).must_equal(1)
        _(@broadcast_refresh_to_call.pargs).must_equal([:current_game])
      end

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns 0" do
          _(subject.increment).must_equal(1)
        end
      end

      context "GIVEN a cache hit" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new(9) } }

        it "returns the expected Integer" do
          _(subject.increment).must_equal(10)
        end
      end
    end

    describe ".decrement" do
      before do
        @broadcast_refresh_to_called_count = 0
        MuchStub.on_call(Turbo::StreamsChannel, :broadcast_refresh_to) { |call|
          @broadcast_refresh_to_call = call
          @broadcast_refresh_to_called_count += 1
        }
      end

      subject { unit_class }

      it "calls Turbo::StreamsChannel.broadcasts_refresh_to" do
        subject.increment
        _(@broadcast_refresh_to_called_count).must_equal(1)
        _(@broadcast_refresh_to_call.pargs).must_equal([:current_game])
      end

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns 0" do
          _(subject.decrement).must_equal(0)
        end
      end

      context "GIVEN a cache hit" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new(9) } }

        it "returns the expected Integer" do
          _(subject.decrement).must_equal(8)
        end
      end
    end

    describe ".clear" do
      before { MuchStub.(Rails, :cache) { CacheDouble.new } }

      subject { unit_class }

      it "returns true" do
        _(subject.clear).must_equal(true)
      end
    end
  end

  class CacheDouble
    def initialize(value = nil)
      @value = value
    end

    def fetch(_, default = nil) = value || default || yield
    def increment(*) = value.to_i.next
    def decrement(*) = value.to_i.pred
    def write(_, new_value) = self.value = new_value
    def delete(*) = true

    private

    attr_accessor :value
  end
end
