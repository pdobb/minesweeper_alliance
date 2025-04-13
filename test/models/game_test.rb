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

  describe "#start" do
    before do
      MuchStub.on_call(Board::RandomlyPlaceMines, :call) { |call|
        @randomly_place_mines_call = call
      }
    end

    given "Game#status_standing_by? = true" do
      subject { standing_by1 }

      it "orchestrates the expected updates and returns the Game" do
        result =
          _(-> {
            subject.start(seed_cell: nil, user: user1)
          }).must_change_all([
            ["subject.started_at"],
            [
              "subject.status",
              from: subject.status_standing_by,
              to: subject.status_sweep_in_progress,
            ],
          ])
        _(result).must_be_same_as(subject)
        _(@randomly_place_mines_call.kargs.fetch(:seed_cell)).must_be_nil
      end
    end

    given "Game#status_standing_by? = false" do
      subject { win1 }

      it "returns the Game without orchestrating any changes" do
        result =
          _(-> {
            subject.start(seed_cell: nil, user: user1)
          }).wont_change_all([
            ["subject.started_at"],
            ["subject.status"],
          ])
        _(result).must_be_same_as(subject)
        _(@randomly_place_mines_call).must_be_nil
      end
    end
  end

  describe "#end_in_victory" do
    given "a Game that's still on" do
      subject { standing_by1.start(seed_cell: nil, user: user1) }

      it "updates Game#ended_at" do
        _(-> { subject.end_in_victory(user: user1) }).must_change(
          "subject.ended_at",
          from: nil)
      end

      it "sets the expected Status" do
        _(-> { subject.end_in_victory(user: user1) }).must_change(
          "subject.status",
          to: Game.status_alliance_wins)
      end

      it "sets Game stats" do
        _(-> { subject.end_in_victory(user: user1) }).must_change_all([
          ["subject.score", from: nil],
          ["subject.bbbv", from: nil],
          ["subject.bbbvps", from: nil],
          ["subject.efficiency", from: nil],
        ])
      end
    end

    given "a Game that's already over" do
      before do
        MuchStub.on_call(subject, :touch) { |call|
          @touch_call = call
        }
      end

      subject { win1 }

      it "returns the Game without orchestrating any changes" do
        result = subject.end_in_victory(user: user1)
        _(result).must_be_same_as(subject)
        _(@touch_call).must_be_nil
      end
    end
  end

  describe "#end_in_defeat" do
    given "a Game that's still on" do
      subject { standing_by1.start(seed_cell: nil, user: user1) }

      it "updates Game#ended_at" do
        _(-> { subject.end_in_defeat(user: user1) }).must_change(
          "subject.ended_at",
          from: nil)
      end

      it "sets the expected Status" do
        _(-> { subject.end_in_defeat(user: user1) }).must_change(
          "subject.status",
          to: Game.status_mines_win)
      end

      it "doesn't set Game stats" do
        _(-> { subject.end_in_defeat(user: user1) }).wont_change_all([
          ["subject.score", from: nil],
          ["subject.bbbv", from: nil],
          ["subject.bbbvps", from: nil],
          ["subject.efficiency", from: nil],
        ])
      end
    end

    given "a Game that's already over" do
      before do
        MuchStub.on_call(subject, :touch) { |call|
          @touch_call = call
        }
      end

      subject { win1 }

      it "returns the Game without orchestrating any changes" do
        result = subject.end_in_defeat(user: user1)
        _(result).must_be_same_as(subject)
        _(@touch_call).must_be_nil
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
        to: now)
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

  describe "#on?" do
    given "Game#status_standing_by? = true" do
      subject { new_game }

      it "returns true" do
        _(subject.on?).must_equal(true)
      end
    end

    given "Game#status_sweep_in_progress? = true" do
      subject { new_game.set_status_sweep_in_progress }

      it "returns true" do
        _(subject.on?).must_equal(true)
      end
    end

    given "Game#status_alliance_wins? = true" do
      subject { new_game.set_status_alliance_wins }

      it "returns false" do
        _(subject.on?).must_equal(false)
      end
    end

    given "Game#status_mines_win? = true" do
      subject { new_game.set_status_mines_win }

      it "returns false" do
        _(subject.on?).must_equal(false)
      end
    end
  end

  describe "#over?" do
    given "Game#status_standing_by? = true" do
      subject { new_game }

      it "returns false" do
        _(subject.over?).must_equal(false)
      end
    end

    given "Game#status_sweep_in_progress? = true" do
      subject { new_game.set_status_sweep_in_progress }

      it "returns false" do
        _(subject.over?).must_equal(false)
      end
    end

    given "Game#status_alliance_wins? = true" do
      subject { new_game.set_status_alliance_wins }

      it "returns true" do
        _(subject.over?).must_equal(true)
      end
    end

    given "Game#status_mines_win? = true" do
      subject { new_game.set_status_mines_win }

      it "returns true" do
        _(subject.over?).must_equal(true)
      end
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
        standing_by1.start(seed_cell: nil, user: user1)
        standing_by1.end_in_victory(user: user1)
      }

      it "returns true" do
        _(subject.just_ended?).must_equal(true)
      end
    end
  end

  describe "#ended_in_victory?" do
    given "Game#status_alliance_wins? = true" do
      subject { win1 }

      it "returns true" do
        _(subject.ended_in_victory?).must_equal(true)
      end
    end

    given "Game#status_alliance_wins? = false'" do
      subject { [loss1, standing_by1].sample }

      it "returns false" do
        _(subject.ended_in_victory?).must_equal(false)
      end
    end
  end

  describe "#ended_in_defeat?" do
    given "Game#status_mines_win? = true" do
      subject { loss1 }

      it "returns true" do
        _(subject.ended_in_defeat?).must_equal(true)
      end
    end

    given "Game#status_mines_win? = false" do
      subject { [win1, standing_by1].sample }

      it "returns false" do
        _(subject.ended_in_defeat?).must_equal(false)
      end
    end
  end

  describe "#ended_a_while_ago?" do
    let(:deep_expiration_minutes) { 3.minutes }

    given "Game#on?" do
      subject { standing_by1.start(seed_cell: nil, user: user1) }

      it "returns false" do
        _(subject.ended_a_while_ago?).must_equal(false)
      end
    end

    given "Game#over?" do
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

  describe "#board_settings" do
    given "#board = nil" do
      subject { new_game }

      it "returns the expected Time Range" do
        _(subject.board_settings).must_be_nil
      end
    end

    given "#board != nil" do
      subject { win1 }

      it "returns the expected Time Range" do
        _(subject.board_settings).must_be_instance_of(Board::Settings)
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
          ].sample)
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
