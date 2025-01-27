# frozen_string_literal: true

require "test_helper"

class FleetTrackerTest < ActiveSupport::TestCase
  describe "FleetTracker" do
    let(:unit_class) { FleetTracker }

    before do
      freeze_time
      @old_rails_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
    end

    after do
      Rails.cache = @old_rails_cache
      unfreeze_time
    end

    let(:empty1) { unit_class }
    let(:single_player_registry1) {
      unit_class.add(user1_token)
      unit_class
    }
    let(:two_player_registry1) {
      unit_class.add(user1_token)
      unit_class.add(user2_token)
      unit_class
    }

    let(:user1_token) { users(:user1).token }
    let(:user2_token) { users(:user2).token }

    let(:expires_at) { nil }
    let(:created_at) { Time.now.utc }

    describe ".registry" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns an empty Array" do
          _(subject.registry.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        subject { single_player_registry1 }

        it "returns the expected collection" do
          _(subject.registry.to_a).must_equal([
            { token: user1_token, active: false, expires_at:, created_at: },
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

        it "adds a new entry for the given token" do
          result = subject.add(user1_token)
          _(result.to_a.map(&:to_h)).must_equal([
            { token: user1_token, active: false, expires_at:, created_at: },
          ])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a repeat token" do
          subject { single_player_registry1 }

          it "doesn't add a new entry for the given token" do
            _(-> { subject.add(user1_token) }).wont_change(
              "subject.registry.to_a")
          end
        end

        context "GIVEN a new registry entry" do
          subject { single_player_registry1 }

          it "adds a new token" do
            result = subject.add(user2_token)
            _(result.to_a).must_equal([
              { token: user1_token, active: false, expires_at:, created_at: },
              { token: user2_token, active: false, expires_at:, created_at: },
            ])
          end
        end
      end
    end

    describe ".add!" do
      before do
        MuchStub.on_call(WarRoomChannel, :broadcast_append) { |call|
          @broadcast_append_call = call
        }
      end

      subject { empty1 }

      it "calls Game::Current::BroadcastFleetRemovalJob, as expected" do
        subject.add!(user1_token)
        _(@broadcast_append_call.kargs[:target]).must_equal("fleetRoster")
        _(@broadcast_append_call.kargs[:partial]).must_equal(
          "home/roster/listing")
      end
    end

    describe ".activate" do
      context "GIVEN a new token" do
        let(:new_token1) { "NEW_TOKEN1" }

        subject { empty1 }

        it "adds an active token" do
          _(-> { subject.activate(new_token1) }).must_change(
            "subject.registry.to_a",
            from: [],
            to: [{ token: new_token1, active: true, expires_at:, created_at: }])
        end
      end

      context "GIVEN an existing token" do
        subject { single_player_registry1 }

        it "activates the entry for the given token" do
          _(-> { subject.activate(user1_token) }).must_change(
            "subject.registry.to_a",
            from: [
              { token: user1_token, active: false, expires_at:, created_at: },
            ],
            to: [
              { token: user1_token, active: true, expires_at:, created_at: },
            ])
        end
      end
    end

    describe ".activate!" do
      before do
        MuchStub.on_call(WarRoomChannel, :broadcast_update) { |call|
          @broadcast_update_call = call
        }
      end

      subject { single_player_registry1 }

      context "GIVEN an inactive entry" do
        it "calls Home::Roster.broadcast_fleet_participation_status_update" do
          subject.activate!(user1_token)
          _(@broadcast_update_call.kargs[:html]).must_equal("⛴️")
        end
      end

      context "GIVEN an active entry" do
        before do
          subject.activate(user1_token)
        end

        it "doesn't call "\
           "Home::Roster.broadcast_fleet_participation_status_update" do
          subject.activate!(user1_token)
          _(@broadcast_fleet_participation_status_update_called).must_be_nil
        end
      end
    end

    describe ".remove" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns the expected collection" do
          result = subject.remove(user1_token)
          _(result.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single registry entry" do
          subject { single_player_registry1 }

          it "expires the entry" do
            result = subject.remove(user1_token)
            _(result.to_a).must_equal([
              {
                token: user1_token,
                active: false,
                expires_at: 2.seconds.from_now,
                created_at:,
              },
            ])
          end
        end

        context "GIVEN multiple registry entries" do
          subject { two_player_registry1 }

          it "expires the expected entry" do
            result = subject.remove(user2_token)
            _(result.to_a).must_equal([
              { token: user1_token, active: false, expires_at:, created_at: },
              {
                token: user2_token,
                active: false,
                expires_at: 2.seconds.from_now,
                created_at:,
              },
            ])
          end
        end
      end

      context "GIVEN #add is called again within the expiration period" do
        subject { single_player_registry1 }

        it "resets the expiration timer" do
          subject.remove(user1_token)

          travel_to(1.second.from_now)
          _(-> { subject.add(user1_token) }).must_change(
            "subject.registry.to_a.first.fetch(:expires_at)",
            from: 1.second.from_now,
            to: expires_at)
        end
      end
    end

    describe ".remove!" do
      before do
        @query_spy =
          MuchStub.spy(
            Game::Current::BroadcastFleetRemovalJob, :set, :perform_later)
      end

      subject { empty1 }

      it "calls Game::Current::BroadcastFleetRemovalJob, as expected" do
        subject.remove!(user1_token)

        _(@query_spy.set_last_called_with.pargs).must_equal([wait: 3.seconds])
        _(@query_spy.perform_later_last_called_with.args).must_equal(
          [user1_token])
      end
    end

    describe ".reset" do
      subject { single_player_registry1 }

      it "resets the collection" do
        subject.reset
        _(subject.registry.to_a).must_equal([])
      end
    end

    describe "Registry" do
      let(:unit_class) { FleetTracker::Registry }

      let(:created_at) { 1.minute.ago.utc }

      let(:empty1) { unit_class.new }
      let(:mixed1) {
        unit_class.new([
          # rubocop:disable Layout/LineLength
          { token: token1, active: true, expires_at: nil, created_at: },
          { token: token2, active: false, expires_at: nil, created_at: },
          { token: expiring_token2, active: true, expires_at: 2.seconds.from_now, created_at: },
          { token: expiring_token1, active: true, expires_at: 1.second.from_now, created_at: },
          { token: expired_token1, active: true, expires_at: Time.current, created_at: },
          { token: expired_token2, active: true, expires_at: 1.second.ago, created_at: },
          # rubocop:enable Layout/LineLength
        ])
      }

      let(:token1) { "TOKEN1" }
      let(:token2) { "TOKEN2" }
      let(:expiring_token1) { "EXPIRING_TOKEN1" }
      let(:expiring_token2) { "EXPIRING_TOKEN2" }
      let(:expired_token1) { "EXPIRED_TOKEN3" }
      let(:expired_token2) { "EXPIRED_TOKEN2" }

      describe "#tokens" do
        subject { mixed1 }

        it "returns an Array containing just the unexpired tokens" do
          _(subject.tokens).must_equal( # Total Time Traveled: 0 seconds
            [token1, token2, expiring_token2, expiring_token1])

          travel_to(1.second.from_now)  # Total Time Traveled: 1 second
          _(subject.tokens).must_equal(
            [token1, token2, expiring_token2])

          travel_to(1.second.from_now)  # Total Time Traveled: 2 second
          _(subject.tokens).must_equal(
            [token1, token2])
        end
      end
    end
  end
end
