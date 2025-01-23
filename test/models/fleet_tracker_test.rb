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
            { token: user1_token, active: false, expires_at: nil },
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
          _(result.to_a).must_equal([
            { token: user1_token, active: false, expires_at: nil },
          ])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a repeat token" do
          subject { single_player_registry1 }

          it "doesn't add a new entry for the given token" do
            result = subject.add(user1_token)
            _(result.to_a).must_equal([
              { token: user1_token, active: false, expires_at: nil },
            ])
          end
        end

        context "GIVEN a new registry entry" do
          subject { single_player_registry1 }

          it "adds a new token" do
            result = subject.add(user2_token)
            _(result.to_a).must_equal([
              { token: user1_token, active: false, expires_at: nil },
              { token: user2_token, active: false, expires_at: nil },
            ])
          end
        end
      end
    end

    describe ".add!" do
      before do
        @query_spy =
          MuchStub.spy(
            Games::Current::BroadcastFleetUpdatesJob, :set, :perform_later)
      end

      subject { empty1 }

      it "calls Games::Current::BroadcastFleetUpdatesJob, as expected" do
        subject.add!(token: user1_token)

        _(@query_spy.set_last_called_with.pargs).must_equal([wait: 0.seconds])
        _(@query_spy.perform_later_last_called_with.args).must_equal([])
      end
    end

    describe ".activate" do
      context "GIVEN a new token" do
        subject { empty1 }

        it "doesn't add or activate anything for the given token" do
          result = subject.activate("UNRECOGNIZED_TOKEN1")
          _(result.to_a).must_equal([])
        end
      end

      context "GIVEN an existing token" do
        subject { single_player_registry1 }

        it "activates the entry for the given token" do
          _(-> { subject.activate(user1_token) }).must_change(
            "subject.registry.to_a",
            from: [{ token: user1_token, active: false, expires_at: nil }],
            to: [{ token: user1_token, active: true, expires_at: nil }])
        end
      end
    end

    describe ".activate!" do
      before do
        MuchStub.(WarRoomChannel, :broadcast_update) {
          @broadcast_fleet_participation_status_update_called = true
        }
      end

      subject { single_player_registry1 }

      context "GIVEN an inactive entry" do
        it "calls Home::Roster.broadcast_fleet_participation_status_update" do
          subject.activate!(token: user1_token)

          _(@broadcast_fleet_participation_status_update_called).
            must_equal(true)
        end
      end

      context "GIVEN an active entry" do
        before do
          subject.activate(user1_token)
        end

        it "returns nil and doesn't call "\
           "Home::Roster.broadcast_fleet_participation_status_update" do
          result = subject.activate!(token: user1_token)
          _(result).must_be_nil
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

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove(user1_token)
              _(result.to_a).must_equal([
                {
                  token: user1_token,
                  active: false,
                  expires_at: 2.seconds.from_now,
                },
              ])
            end
          end
        end

        context "GIVEN multiple registry entries" do
          subject { two_player_registry1 }

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove(user2_token)
              _(result.to_a).must_equal([
                { token: user1_token, active: false, expires_at: nil },
                {
                  token: user2_token,
                  active: false,
                  expires_at: 2.seconds.from_now,
                },
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
            Games::Current::BroadcastFleetUpdatesJob, :set, :perform_later)
      end

      subject { empty1 }

      it "calls Games::Current::BroadcastFleetUpdatesJob, as expected" do
        subject.remove!(token: user1_token)

        _(@query_spy.set_last_called_with.pargs).must_equal([wait: 3.seconds])
        _(@query_spy.perform_later_last_called_with.args).must_equal([])
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
          subject.remove(user1_token)
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
