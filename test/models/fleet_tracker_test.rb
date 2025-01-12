# frozen_string_literal: true

require "test_helper"

class FleetTrackerTest < ActiveSupport::TestCase
  describe "FleetTracker" do
    let(:unit_class) { FleetTracker }

    before do
      @old_rails_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
    end

    after do
      Rails.cache = @old_rails_cache
    end

    let(:empty1) { unit_class }
    let(:single_player_registry1) {
      unit_class.add("user_token1")
      unit_class
    }
    let(:two_player_registry1) {
      unit_class.add("user_token1")
      unit_class.add("user_token2")
      unit_class
    }

    describe ".registry" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns an empty collection" do
          _(subject.registry.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        subject { single_player_registry1 }

        it "returns the expected collection" do
          _(subject.registry.to_a).must_equal([
            { token: "user_token1", expires_at: nil },
          ])
        end
      end
    end

    describe ".count" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns 0" do
          _(subject.count).must_equal(0)
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single registry entry" do
          subject { single_player_registry1 }

          it "returns the expected Integer" do
            _(subject.count).must_equal(1)
          end
        end

        context "GIVEN multiple registry entries" do
          subject { two_player_registry1 }

          it "returns the expected Integer" do
            _(subject.count).must_equal(2)
          end
        end
      end
    end

    describe ".add" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns the expected collection" do
          result = subject.add("user_token1")
          _(result.to_a).must_equal([
            { token: "user_token1", expires_at: nil },
          ])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN the same registry entry" do
          subject { single_player_registry1 }

          it "returns the expected collection" do
            result = subject.add("user_token1")
            _(result.to_a).must_equal([
              { token: "user_token1", expires_at: nil },
            ])
          end
        end

        context "GIVEN a new registry entry" do
          subject { single_player_registry1 }

          it "returns the expected collection" do
            result = subject.add("user_token2")
            _(result.to_a).must_equal([
              { token: "user_token1", expires_at: nil },
              { token: "user_token2", expires_at: nil },
            ])
          end
        end
      end
    end

    describe ".add!" do
      before do
        @query_spy =
          MuchStub.spy(
            BroadcastCurrentFleetSizeJob,
            :set,
            perform_later: "Test Result")
      end

      subject { empty1 }

      it "calls BroadcastCurrentFleetSizeJob, as expected" do
        subject.add!(token: "user_token1", stream: "test_stream")

        _(@query_spy.set_last_called_with.pargs).must_equal([wait: 0.seconds])
        _(@query_spy.perform_later_last_called_with.pargs).must_equal(
          ["test_stream"])
      end
    end

    describe ".remove" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns the expected collection" do
          result = subject.remove("user_token1")
          _(result.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single registry entry" do
          subject { single_player_registry1 }

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove("user_token1")
              _(result.to_a).must_equal([
                { token: "user_token1", expires_at: 2.seconds.from_now },
              ])
            end
          end
        end

        context "GIVEN multiple registry entries" do
          subject { two_player_registry1 }

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove("user_token2")
              _(result.to_a).must_equal([
                { token: "user_token1", expires_at: nil },
                { token: "user_token2", expires_at: 2.seconds.from_now },
              ])
            end
          end
        end
      end
    end

    describe ".remove!" do
      before do
        @query_spy =
          MuchStub.spy(
            BroadcastCurrentFleetSizeJob,
            :set,
            perform_later: "Test Result")
      end

      subject { empty1 }

      it "calls BroadcastCurrentFleetSizeJob, as expected" do
        subject.remove!(token: "user_token1", stream: "test_stream")

        _(@query_spy.set_last_called_with.pargs).must_equal([wait: 3.seconds])
        _(@query_spy.perform_later_last_called_with.pargs).must_equal(
          ["test_stream"])
      end
    end

    describe ".prune" do
      context "GIVEN an empty registry" do
        subject { empty1 }

        it "returns the expected collection" do
          result = subject.prune
          _(result.to_a).must_equal([])
        end
      end

      context "GIVEN an expiring registry entry" do
        before do
          subject.remove("user_token1")
        end

        subject { single_player_registry1 }

        it "returns the expected collection after the expiration delay" do
          _(subject.prune.to_a).wont_equal([])
          travel_to(3.seconds.from_now) do
            _(subject.prune.to_a).must_equal([])
          end
        end
      end
    end

    describe ".reset" do
      subject { single_player_registry1 }

      it "resets the collection" do
        subject.reset
        _(subject.registry.to_a).must_equal([])
      end
    end
  end
end
