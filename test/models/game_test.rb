# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  let(:win1) { games(:win1) }
  let(:loss1) { games(:loss1) }
  let(:standing_by1) { games(:standing_by1) }
  let(:new_game) { Game.new }
  let(:preset_settings1) { Board::Settings.beginner }
  let(:custom_settings1) { Board::Settings[6, 6, 4] }

  let(:user1) { users(:user1) }

  describe ".display_id_width" do
    before do
      subject.instance_variable_set(:@display_id_width, nil)
    end

    subject { Game }

    given "largest_id < 4 digits" do
      before do
        MuchStub.(subject, :largest_id) { 1 }
      end

      it "returns the expected String" do
        _(subject.display_id_width).must_equal(4)
      end
    end

    given "largest_id > 4 digits" do
      before do
        MuchStub.(subject, :largest_id) { 12_345 }
      end

      it "returns the expected String" do
        _(subject.display_id_width).must_equal(5)
      end
    end
  end

  describe "#validate" do
    describe "#type" do
      subject { Game.new(type: type1) }

      given "valid, unique #type" do
        let(:type1) { Game::ALL_TYPES.sample }

        it "passes validation" do
          subject.validate

          _(subject.errors[:type]).must_be_empty
        end
      end

      given "no #type" do
        let(:type1) { nil }

        it "fails validation" do
          subject.validate

          _(subject.errors[:type]).must_include(ValidationError.presence)
        end
      end
    end
  end

  describe "#display_id" do
    before do
      Game.instance_variable_set(:@display_id_width, nil)
      MuchStub.(subject.class, :largest_id) { 1 }
      MuchStub.(subject, :id) { 1 }
    end

    subject { win1 }

    it "returns the expected String" do
      _(subject.display_id).must_equal("#0001")
    end
  end

  describe "#type" do
    given "a standard Difficulty Level" do
      subject {
        Game::Factory.build_for(settings: preset_settings1)
      }

      it "returns the expected String" do
        _(subject.type).must_equal("Beginner")
      end
    end

    given "a custom Difficulty Level" do
      subject {
        Game::Factory.build_for(settings: custom_settings1)
      }

      it "returns the expected String" do
        _(subject.type).must_equal("Custom")
      end
    end
  end

  describe "#update_started_at" do
    let(:now) { Time.current.at_beginning_of_minute }

    subject { standing_by1 }

    it "updates #started_at" do
      _(-> { subject.update_started_at(time: now) }).must_change(
        "subject.started_at",
        from: nil,
        to: now,
      )
    end
  end

  describe "#update_ended_at" do
    let(:now) { Time.current.at_beginning_of_minute }

    subject { standing_by1 }

    it "updates #ended_at" do
      _(-> { subject.update_ended_at(time: now) }).must_change_all([
        ["subject.ended_at", from: nil, to: now],
        ["subject.just_ended?", from: false, to: true],
      ])
    end
  end

  describe "#just_ended?" do
    given "Game#ended_at = nil" do
      subject { new_game }

      it "returns false" do
        _(subject.just_ended?).must_equal(false)
      end
    end

    given "Game#ended_at was not just set" do
      subject { win1 }

      it "returns false" do
        _(subject.just_ended?).must_equal(false)
      end
    end

    given "Game#ended_at was just set/saved" do
      subject {
        Game::Start.(game: standing_by1, user: user1, seed_cell: nil)
        Game::EndInVictory.(game: standing_by1, user: user1)
      }

      it "returns true" do
        _(subject.just_ended?).must_equal(true)
      end
    end
  end

  describe "#ended_a_while_ago?" do
    let(:deep_expiration_minutes) { 3.minutes }

    given "Game::Status.on?(...) == true" do
      subject {
        Game::Start.(game: standing_by1, user: user1, seed_cell: nil)
      }

      it "returns false" do
        _(subject.ended_a_while_ago?).must_equal(false)
      end
    end

    given "Game::Status.over?(...) == true" do
      subject { win1 }

      given "a recent Game#ended_at" do
        it "returns true" do
          travel_to((deep_expiration_minutes - 1.second).from_now) do
            _(subject.ended_a_while_ago?).must_equal(true)
          end
        end
      end

      given "a distant Game#ended_at" do
        it "returns true" do
          travel_to(deep_expiration_minutes.from_now) do
            _(subject.ended_a_while_ago?).must_equal(true)
          end
        end
      end
    end
  end

  describe "#user_bests" do
    given "a bestable Game type" do
      subject {
        Game::Factory.build_for(
          settings: [
            Board::Settings.beginner,
            Board::Settings.intermediate,
            Board::Settings.expert,
          ].sample,
        )
      }

      it "returns the expected type" do
        result = subject.user_bests(user: user1)
        target_types = [
          User::Bests::Beginner,
          User::Bests::Intermediate,
          User::Bests::Expert,
        ]

        _(result.class.in?(target_types)).must_equal(true)
      end
    end

    given "a non-bestable Game type" do
      subject { win1 }

      it "raises TypeError" do
        _(-> { subject.user_bests(user: user1) }).must_raise(TypeError)
      end
    end
  end
end
