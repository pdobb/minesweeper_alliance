# frozen_string_literal: true

require "test_helper"

class DutyRosterTest < ActiveSupport::TestCase
  describe "DutyRoster" do
    let(:unit_class) { DutyRoster }

    before do
      @old_rails_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
    end

    after do
      Rails.cache = @old_rails_cache
    end

    let(:empty1) { unit_class }
    let(:single_player_duty_roster1) {
      unit_class.add("user1")
      unit_class
    }
    let(:two_player_duty_roster1) {
      unit_class.add("user1")
      unit_class.add("user2")
      unit_class
    }

    describe ".participants" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns an empty collection" do
          _(subject.participants.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        subject { single_player_duty_roster1 }

        it "returns the expected collection" do
          _(subject.participants.to_a).must_equal([
            { user_token: "user1", expires_at: nil },
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
        context "GIVEN a single participant" do
          subject { single_player_duty_roster1 }

          it "returns the expected Integer" do
            _(subject.count).must_equal(1)
          end
        end

        context "GIVEN multiple participants" do
          subject { two_player_duty_roster1 }

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
          result = subject.add("user1")
          _(result.to_a).must_equal([
            { user_token: "user1", expires_at: nil },
          ])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a the same participant" do
          subject { single_player_duty_roster1 }

          it "returns the expected collection" do
            result = subject.add("user1")
            _(result.to_a).must_equal([
              { user_token: "user1", expires_at: nil },
            ])
          end
        end

        context "GIVEN a new participant" do
          subject { single_player_duty_roster1 }

          it "returns the expected collection" do
            result = subject.add("user2")
            _(result.to_a).must_equal([
              { user_token: "user1", expires_at: nil },
              { user_token: "user2", expires_at: nil },
            ])
          end
        end
      end
    end

    describe ".remove" do
      context "GIVEN a cache miss" do
        subject { empty1 }

        it "returns the expected collection" do
          result = subject.remove("user1")
          _(result.to_a).must_equal([])
        end
      end

      context "GIVEN a cache hit" do
        context "GIVEN a single participant" do
          subject { single_player_duty_roster1 }

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove("user1")
              _(result.to_a).must_equal([
                { user_token: "user1", expires_at: 2.seconds.from_now },
              ])
            end
          end
        end

        context "GIVEN multiple participants" do
          subject { two_player_duty_roster1 }

          it "returns the expected collection" do
            freeze_time do
              result = subject.remove("user2")
              _(result.to_a).must_equal([
                { user_token: "user1", expires_at: nil },
                { user_token: "user2", expires_at: 2.seconds.from_now },
              ])
            end
          end
        end
      end
    end

    describe ".clear" do
      subject { single_player_duty_roster1 }

      it "clears the collection" do
        subject.clear
        _(subject.participants.to_a).must_equal([])
      end
    end
  end
end
