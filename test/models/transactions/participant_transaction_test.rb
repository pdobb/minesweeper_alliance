# frozen_string_literal: true

require "test_helper"

class ParticipantTransactionTest < ActiveSupport::TestCase
  describe "ParticipantTransaction" do
    let(:unit_class) { ParticipantTransaction }

    let(:win1_participant_transaction_user1) {
      participant_transactions(:win1_participant_transaction_user1)
    }
    let(:standing_by1_participant_transaction_user2) {
      participant_transactions(:standing_by1_participant_transaction_user2)
    }

    let(:user1) { users(:user1) }
    let(:user2) { users(:user2) }

    let(:win1) { games(:win1) }
    let(:standing_by1) { games(:standing_by1) }

    describe "#save(validate: false)" do
      subject { unit_class.take }

      it "raises ActiveRecord::RecordNotUnique" do
        exception =
          _(-> {
            subject.dup.save(validate: false)
          }).must_raise(ActiveRecord::RecordNotUnique)

        _(exception.message).must_include(
          "PG::UniqueViolation: ERROR:  "\
          "duplicate key value violates unique constraint "\
          '"index_participant_transactions_on_user_id_and_game_id"')
      end
    end

    describe ".create_between" do
      subject { unit_class }

      context "GIVEN a new, unique User + Game pair" do
        it "creates the expected record, and returns it" do
          result =
            _(-> {
              subject.create_between(user: user1, game: standing_by1)
            }).must_change("unit_class.count")
          _(result).must_be_instance_of(subject)
          _(result.user).must_be_same_as(user1)
          _(result.game).must_be_same_as(standing_by1)
        end
      end

      context "GIVEN an existing, non-unique User + Game pair" do
        it "fails validation" do
          result =
            _(-> {
              subject.create_between(user: user2, game: standing_by1)
            }).wont_change("unit_class.count")
          _(result.valid?).must_equal(false)
          _(result.errors[:user]).must_include(ValidationError.taken)
        end
      end
    end

    describe ".activate_between" do
      subject { unit_class }

      context "GIVEN an existing pair" do
        context "GIVEN #active == false" do
          it "sets #active = true" do
            freeze_time do
              _(-> {
                subject.activate_between(user: user2, game: standing_by1)
              }).must_change(
                <<~RUBY.squish,
                  subject.
                    find_between!(user: user2, game: standing_by1).
                    attributes.
                    slice("active", "started_actively_participating_at")
                RUBY
                from: {
                  "active" => false,
                  "started_actively_participating_at" => nil,
                },
                to: {
                  "active" => true,
                  "started_actively_participating_at" => Time.current,
                })
            end
          end
        end

        context "GIVEN #active == true" do
          it "doesn't update" do
            _(-> {
              subject.activate_between(user: user1, game: win1)
            }).wont_change(
              "subject.find_between!(user: user1, game: win1).attributes")
          end
        end
      end

      context "GIVEN a non-existent pair" do
        it "raises ActiveRecord::RecordNotFound" do
          _(-> { subject.activate_between(user: user2, game: win1) }).
            must_raise(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe ".find_between!" do
      subject { unit_class }

      context "GIVEN an existing pair" do
        it "returns the expected record" do
          result = subject.find_between!(user: user1, game: win1)
          _(result).must_equal(win1_participant_transaction_user1)
        end
      end

      context "GIVEN a non-existent pair" do
        it "raises ActiveRecord::RecordNotFound" do
          _(-> { subject.find_between!(user: user2, game: win1) }).must_raise(
            ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
