# frozen_string_literal: true

require "test_helper"

class DutyRosterTest < ActiveSupport::TestCase
  describe "DutyRoster" do
    let(:unit_class) { DutyRoster }

    let(:participants1) { %w[user1] }
    let(:participants2) { %w[user1 user2] }

    describe ".participants" do
      subject { unit_class }

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns []" do
          _(subject.participants).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new(participants1) } }

        it "returns the expected Integer" do
          _(subject.participants).must_equal(participants1)
        end
      end
    end

    describe ".count" do
      subject { unit_class }

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns 0" do
          _(subject.count).must_equal(0)
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single participant" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants1) } }

          it "returns the expected Integer" do
            _(subject.count).must_equal(1)
          end
        end

        context "GIVEN multiple participants" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants2) } }

          it "returns the expected Integer" do
            _(subject.count).must_equal(2)
          end
        end
      end
    end

    describe ".add" do
      subject { unit_class }

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns the expected Array" do
          _(subject.add("new_user1")).must_equal(["new_user1"])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single participant" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants1) } }

          it "returns the expected Array" do
            _(subject.add(participants1.first)).must_equal(participants1)
          end
        end

        context "GIVEN multiple participants" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants2) } }

          it "returns the expected Array" do
            _(subject.add(participants2.last)).must_equal(participants2)
          end
        end
      end
    end

    describe ".remove" do
      subject { unit_class }

      context "GIVEN a cache miss" do
        before { MuchStub.(Rails, :cache) { CacheDouble.new } }

        it "returns the expected Array" do
          _(subject.remove("new_user1")).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single participant" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants1) } }

          it "returns the expected Array" do
            _(subject.remove(participants1.first)).must_equal([])
          end
        end

        context "GIVEN multiple participants" do
          before { MuchStub.(Rails, :cache) { CacheDouble.new(participants2) } }

          it "returns the expected Array" do
            _(subject.remove(participants2.last)).must_equal(participants1)
          end
        end
      end
    end

    describe ".clear" do
      before { MuchStub.(Rails, :cache) { CacheDouble.new(participants1) } }

      subject { unit_class }

      it "calls :delete on Rails.cache" do
        _(subject.clear).must_equal("CACHE_DELETE_CALLED")
      end
    end
  end

  class CacheDouble
    def initialize(value = nil)
      @value = value
    end

    def fetch(_, default = nil) = value || default || yield
    def write(_, new_value) = self.value = new_value
    def delete(*) = "CACHE_DELETE_CALLED"

    private

    attr_accessor :value
  end
end
