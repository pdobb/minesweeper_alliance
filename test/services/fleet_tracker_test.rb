# frozen_string_literal: true

require "test_helper"

class FleetTrackerTest < ActiveSupport::TestCase
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
  let(:expiration_seconds) { 2.seconds }
  let(:deep_expiration_minutes) { 3.minutes }

  describe ".registry" do
    context "GIVEN a cache miss" do
      subject { empty1 }

      it "returns an empty Array" do
        _(subject.to_a).must_equal([])
      end
    end

    context "GIVEN a cache hit" do
      subject { single_player_registry1 }

      it "returns the expected collection" do
        _(subject.to_a).must_equal([
          { token: user1_token, active: false, expires_at: },
        ])
      end
    end
  end

  describe ".size" do
    context "GIVEN a cache miss" do
      subject { empty1 }

      it "returns 0" do
        _(subject.size).must_equal(0)
      end
    end

    context "GIVEN a cache hit" do
      context "GIVEN a single registry entry" do
        subject { single_player_registry1 }

        it "returns the expected Integer" do
          _(subject.size).must_equal(1)
        end
      end

      context "GIVEN multiple registry entries" do
        subject { two_player_registry1 }

        it "returns the expected Integer" do
          _(subject.size).must_equal(2)
        end
      end
    end
  end

  describe ".add" do
    context "GIVEN a cache miss" do
      subject { empty1 }

      it "adds a new entry for the given token" do
        result = subject.add(user1_token)
        _(result).must_be_instance_of(unit_class::Registry::Entry)
        _(subject.to_a).must_equal([
          { token: user1_token, active: false, expires_at: },
        ])
      end
    end

    context "GIVEN a cache hit" do
      context "GIVEN a repeat token" do
        subject { single_player_registry1 }

        it "doesn't add a new entry for the given token" do
          _(-> { subject.add(user1_token) }).wont_change(
            "subject.entries")
        end
      end

      context "GIVEN a new registry entry" do
        subject { single_player_registry1 }

        it "adds a new token" do
          result = subject.add(user2_token)
          _(result).must_be_instance_of(unit_class::Registry::Entry)
          _(subject.to_a).must_equal([
            { token: user1_token, active: false, expires_at: },
            { token: user2_token, active: false, expires_at: },
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
          "subject.to_a",
          from: [],
          to: [{ token: new_token1, active: true, expires_at: }])
      end
    end

    context "GIVEN an existing token" do
      subject { single_player_registry1 }

      it "activates the entry for the given token" do
        _(-> { subject.activate(user1_token) }).must_change(
          "subject.to_a",
          from: [
            { token: user1_token, active: false, expires_at: },
          ],
          to: [
            { token: user1_token, active: true, expires_at: },
          ])
      end
    end
  end

  describe ".activate!" do
    before do
      MuchStub.on_call(WarRoomChannel, :broadcast_update) { |call|
        @broadcast_update_call = call
      }
      MuchStub.on_call(WarRoomChannel, :broadcast_replace) { |call|
        @broadcast_replace_call = call
      }
    end

    subject { single_player_registry1 }

    context "GIVEN an inactive entry" do
      it "broadcasts the expected update" do
        subject.activate!(user1_token)
        _(@broadcast_update_call.kargs).must_equal(
          { target: "fleetSize", html: 1 })
        _(@broadcast_replace_call.kargs[:partial]).must_equal(
          "home/roster/listing")
      end
    end

    context "GIVEN an active entry" do
      before do
        subject.activate(user1_token)
      end

      it "doesn't call "\
         "Home::Roster.broadcast_update_call" do
        subject.activate!(user1_token)
        _(@broadcast_update_call).must_be_nil
        _(@broadcast_replace_call).must_be_nil
      end
    end
  end

  describe ".expire" do
    context "GIVEN no entries" do
      subject { empty1 }

      it "returns the expected collection" do
        result = subject.expire(user1_token)
        _(result.to_a).must_equal([])
      end
    end

    context "GIVEN a cache hit" do
      context "GIVEN a single registry entry" do
        subject { single_player_registry1 }

        it "expires the entry" do
          result = subject.expire(user1_token)
          _(result).must_be_instance_of(unit_class::Registry::Entry)
          _(subject.to_a).must_equal([
            {
              token: user1_token,
              active: false,
              expires_at: expiration_seconds.from_now,
            },
          ])
        end
      end

      context "GIVEN multiple registry entries" do
        subject { two_player_registry1 }

        it "expires the expected entry" do
          result = subject.expire(user2_token)
          _(result).must_be_instance_of(unit_class::Registry::Entry)
          _(subject.to_a).must_equal([
            { token: user1_token, active: false, expires_at: },
            {
              token: user2_token,
              active: false,
              expires_at: expiration_seconds.from_now,
            },
          ])
        end
      end
    end

    context "GIVEN #add is called again within the expiration period" do
      subject { single_player_registry1 }

      it "resets the expiration timer" do
        subject.expire(user1_token)

        travel_to(1.second.from_now)
        _(-> { subject.add(user1_token) }).must_change(
          "subject.entries.first.expires_at",
          from: 1.second.from_now,
          to: expires_at)
      end
    end
  end

  describe ".expire!" do
    before do
      @query_spy =
        MuchStub.spy(
          Home::Roster::Listing::BroadcastEntryExpirationJob,
          :set,
          :perform_later)
    end

    subject { single_player_registry1 }

    it "calls Game::Current::BroadcastFleetRemovalJob, as expected" do
      subject.expire!(user1_token)

      _(@query_spy.set_last_called_with.pargs).must_equal(
        [wait: expiration_seconds])
      _(@query_spy.perform_later_last_called_with.args).must_equal(
        [user1_token])
    end
  end

  describe ".purge_deeply_expired_entries" do
    context "GIVEN no entries present" do
      subject { empty1 }

      it "returns an empty Array" do
        result = subject.purge_deeply_expired_entries
        _(result).must_equal([])
      end
    end

    context "GIVEN no expired entries present" do
      before do
        subject.expire(user1_token)
        travel_to(
          (deep_expiration_minutes + expiration_seconds - 1.second).from_now)
      end

      subject { two_player_registry1 }

      it "returns an empty Array" do
        result = subject.purge_deeply_expired_entries
        _(result).must_equal([])
      end
    end

    context "GIVEN a deeply expired entry is present" do
      before do
        subject.expire(user1_token)
        travel_to((expiration_seconds + deep_expiration_minutes).from_now)
      end

      subject { two_player_registry1 }

      it "removes the entry" do
        result = subject.purge_deeply_expired_entries
        _(result.sample).must_be_instance_of(unit_class::Registry::Entry)
        _(result.map(&:to_h)).must_equal([
          {
            token: user1_token,
            active: false,
            expires_at: deep_expiration_minutes.ago,
          },
        ])
      end
    end
  end

  describe ".purge_deeply_expired_entries!" do
    before do
      MuchStub.on_call(WarRoomChannel, :broadcast_remove) { |call|
        @broadcast_remove_call = call
      }

      subject.expire(user1_token)
      travel_to((expiration_seconds + deep_expiration_minutes).from_now)
    end

    subject { two_player_registry1 }

    it "calls Game::Current::BroadcastFleetRemovalJob, as expected" do
      subject.purge_deeply_expired_entries!
      _(@broadcast_remove_call.kargs[:target]).must_equal(
        "home_roster_listing-7fff4b12-83c2-50b2-845f-52ae10a9aeee")
    end
  end

  describe ".reset" do
    subject { single_player_registry1 }

    it "resets the collection" do
      subject.reset
      _(subject.to_a).must_equal([])
    end
  end

  describe "Registry" do
    let(:unit_class) { FleetTracker::Registry }

    let(:empty1) { unit_class.new }
    let(:mixed1) {
      unit_class.new([
        { token: token1, active: true, expires_at: nil },
        { token: expiring_token1, active: true, expires_at: 1.second.from_now },
        { token: expired_token1, active: true, expires_at: Time.current },
      ])
    }

    let(:token1) { "TOKEN1" }
    let(:expiring_token1) { "EXPIRING_TOKEN1" }
    let(:expired_token1) { "EXPIRED_TOKEN3" }

    describe "#tokens" do
      subject { mixed1 }

      it "returns all token, regardless of expiry" do
        _(subject.entries.pluck(:token)).must_equal(
          [token1, expiring_token1, expired_token1])
      end
    end
  end
end
