# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  ErrorDouble = Class.new(StandardError)

  describe "Game" do
    let(:unit_class) { Game }

    let(:win1) { games(:win1) }
    let(:loss1) { games(:loss1) }
    let(:standing_by1) { games(:standing_by1) }
    let(:new_game) { unit_class.new }
    let(:preset_settings1) { Board::Settings.beginner }
    let(:custom_settings1) { Board::Settings[6, 6, 4] }

    let(:user1) { users(:user1) }

    context "Class Methods" do
      subject { unit_class }

      describe ".create_for" do
        context "GIVEN a current Game already exists" do
          it "raises ActiveRecord::RecordNotUnique" do
            _(-> {
              subject.create_for(settings: custom_settings1)
            }).must_raise(ActiveRecord::RecordNotUnique)
          end
        end

        context "GIVEN no current Game" do
          before { standing_by1.delete }

          it "returns a persisted Game with the expected attributes" do
            result =
              subject.create_for(settings: custom_settings1)
            _(result).must_be_instance_of(unit_class)
            _(result.persisted?).must_equal(true)
            _(result.status_standing_by?).must_equal(true)
            _(result.board).must_be_instance_of(Board)
            _(result.board.cells.sample).must_be_instance_of(Cell)
          end

          context "GIVEN an unexpected failure between Game/Board Save and "\
                  "Cells insertion" do
            before do
              MuchStub.(Board::Generate, :new) {
                raise(ErrorDouble, "Simulated Error for Test Example")
              }
            end

            it "doesn't persist the Game/Board/Cells" do
              _(-> {
                _(-> {
                  subject.create_for(settings: custom_settings1)
                }).must_raise(ErrorDouble)
              }).wont_change_all([
                ["Game.count"], ["Board.count"], ["Cell.count"]
              ])
            end
          end
        end
      end

      describe ".build_for" do
        it "orchestrates building of the expected object graph and returns "\
           "the new Game" do
          result = subject.build_for(settings: custom_settings1)
          _(result).must_be_instance_of(unit_class)
          _(result.board).must_be_instance_of(Board)
          _(result.board.cells).must_be_empty
        end
      end

      describe ".display_id_width" do
        before do
          unit_class.instance_variable_set(:@display_id_width, nil)
        end

        context "GIVEN largest_id < 4 digits" do
          before do
            MuchStub.(subject, :largest_id) { 1 }
          end

          it "returns the expected String" do
            _(subject.display_id_width).must_equal(4)
          end
        end

        context "GIVEN largest_id > 4 digits" do
          before do
            MuchStub.(subject, :largest_id) { 12_345 }
          end

          it "returns the expected String" do
            _(subject.display_id_width).must_equal(5)
          end
        end
      end
    end

    describe "#validate" do
      describe "#type" do
        subject { unit_class.new(type: type1) }

        context "GIVEN valid, unique #type" do
          let(:type1) { unit_class::ALL_TYPES.sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:type]).must_be_empty
          end
        end

        context "GIVEN no #type" do
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
        unit_class.instance_variable_set(:@display_id_width, nil)
        MuchStub.(subject.class, :largest_id) { 1 }
        MuchStub.(subject, :id) { 1 }
      end

      subject { win1 }

      it "returns the expected String" do
        _(subject.display_id).must_equal("#0001")
      end
    end

    describe "#type" do
      context "GIVEN a standard Difficulty Level" do
        subject {
          unit_class.build_for(settings: preset_settings1)
        }

        it "returns the expected String" do
          _(subject.type).must_equal("Beginner")
        end
      end

      context "GIVEN a custom Difficulty Level" do
        subject {
          unit_class.build_for(settings: custom_settings1)
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

      context "GIVEN Game#status_standing_by? = true" do
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

      context "GIVEN Game#status_standing_by? = false" do
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
      context "GIVEN a Game that's still on" do
        subject { standing_by1.start(seed_cell: nil, user: user1) }

        it "updates Game#ended_at" do
          _(-> { subject.end_in_victory(user: user1) }).must_change(
            "subject.ended_at",
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_victory(user: user1) }).must_change(
            "subject.status",
            to: unit_class.status_alliance_wins)
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

      context "GIVEN a Game that's already over" do
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
      context "GIVEN a Game that's still on" do
        subject { standing_by1.start(seed_cell: nil, user: user1) }

        it "updates Game#ended_at" do
          _(-> { subject.end_in_defeat(user: user1) }).must_change(
            "subject.ended_at",
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_defeat(user: user1) }).must_change(
            "subject.status",
            to: unit_class.status_mines_win)
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

      context "GIVEN a Game that's already over" do
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
      context "GIVEN Game#status_standing_by? = true" do
        subject { new_game }

        it "returns true" do
          _(subject.on?).must_equal(true)
        end
      end

      context "GIVEN Game#status_sweep_in_progress? = true" do
        subject { new_game.set_status_sweep_in_progress }

        it "returns true" do
          _(subject.on?).must_equal(true)
        end
      end

      context "GIVEN Game#status_alliance_wins? = true" do
        subject { new_game.set_status_alliance_wins }

        it "returns false" do
          _(subject.on?).must_equal(false)
        end
      end

      context "GIVEN Game#status_mines_win? = true" do
        subject { new_game.set_status_mines_win }

        it "returns false" do
          _(subject.on?).must_equal(false)
        end
      end
    end

    describe "#over?" do
      context "GIVEN Game#status_standing_by? = true" do
        subject { new_game }

        it "returns false" do
          _(subject.over?).must_equal(false)
        end
      end

      context "GIVEN Game#status_sweep_in_progress? = true" do
        subject { new_game.set_status_sweep_in_progress }

        it "returns false" do
          _(subject.over?).must_equal(false)
        end
      end

      context "GIVEN Game#status_alliance_wins? = true" do
        subject { new_game.set_status_alliance_wins }

        it "returns true" do
          _(subject.over?).must_equal(true)
        end
      end

      context "GIVEN Game#status_mines_win? = true" do
        subject { new_game.set_status_mines_win }

        it "returns true" do
          _(subject.over?).must_equal(true)
        end
      end
    end

    describe "#just_ended?" do
      context "GIVEN Game#ended_at = nil" do
        subject { new_game }

        it "returns false" do
          _(subject.just_ended?).must_equal(false)
        end
      end

      context "GIVEN Game#ended_at was not just set" do
        subject { win1 }

        it "returns false" do
          _(subject.just_ended?).must_equal(false)
        end
      end

      context "GIVEN Game#ended_at was just set/saved" do
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
      context "GIVEN Game#status_alliance_wins? = true" do
        subject { win1 }

        it "returns true" do
          _(subject.ended_in_victory?).must_equal(true)
        end
      end

      context "GIVEN Game#status_alliance_wins? = false'" do
        subject { [loss1, standing_by1].sample }

        it "returns false" do
          _(subject.ended_in_victory?).must_equal(false)
        end
      end
    end

    describe "#ended_in_defeat?" do
      context "GIVEN Game#status_mines_win? = true" do
        subject { loss1 }

        it "returns true" do
          _(subject.ended_in_defeat?).must_equal(true)
        end
      end

      context "GIVEN Game#status_mines_win? = false" do
        subject { [win1, standing_by1].sample }

        it "returns false" do
          _(subject.ended_in_defeat?).must_equal(false)
        end
      end
    end

    describe "#engagement_time_range" do
      context "GIVEN Game#on?" do
        subject { standing_by1 }

        it "returns the expected Time Range" do
          _(subject.engagement_time_range).must_equal(
            subject.started_at..)
        end
      end

      context "GIVEN Game#over?" do
        subject { win1 }

        it "returns the expected Time Range" do
          _(subject.engagement_time_range).must_equal(
            subject.started_at..subject.ended_at)
        end
      end
    end

    describe "#duration" do
      context "GIVEN Game#on?" do
        subject { standing_by1.start(seed_cell: nil, user: user1) }

        it "returns nil" do
          _(subject.duration).must_be_nil
        end
      end

      context "GIVEN Game#over?" do
        subject { win1 }

        it "returns the expected Time range" do
          _(subject.duration).must_equal(30.0)
        end
      end
    end

    describe "#board_settings" do
      context "GIVEN #board = nil" do
        subject { new_game }

        it "returns the expected Time Range" do
          _(subject.board_settings).must_be_nil
        end
      end

      context "GIVEN #board != nil" do
        subject { win1 }

        it "returns the expected Time Range" do
          _(subject.board_settings).must_be_instance_of(Board::Settings)
        end
      end
    end

    describe "#bestable_type?" do
      context "GIVEN a bestable type" do
        subject {
          unit_class.build_for(
            settings: [
              Board::Settings.beginner,
              Board::Settings.intermediate,
              Board::Settings.expert,
            ].sample)
        }

        it "returns true" do
          _(subject.bestable_type?).must_equal(true)
        end
      end

      context "GIVEN a non-bestable type" do
        subject {
          unit_class.build_for(
            settings: [
              Board::Settings.pattern("Test Pattern 1"),
              Board::Settings.custom,
            ].sample)
        }

        it "returns false" do
          _(subject.bestable_type?).must_equal(false)
        end
      end
    end

    describe "#user_bests" do
      context "GIVEN a bestable Game type" do
        subject {
          unit_class.build_for(
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

      context "GIVEN a non-bestable Game type" do
        subject { win1 }

        it "raises TypeError" do
          _(-> { subject.user_bests(user: user1) }).must_raise(TypeError)
        end
      end
    end
  end
end
