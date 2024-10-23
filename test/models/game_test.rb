# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  ErrorDouble = Class.new(StandardError)

  describe "Game" do
    let(:unit_class) { Game }

    let(:win1) { games(:win1) }
    let(:loss1) { games(:loss1) }
    let(:standing_by1) { games(:standing_by1) }
    let(:new_game) { Game.new }
    let(:preset_settings1) { Board::Settings.beginner }
    let(:custom_settings1) { Board::Settings[6, 6, 4] }

    context "Class Methods" do
      subject { unit_class }

      describe ".current" do
        context "GIVEN a Game#on? = true Game exists" do
          it "returns the Game#on? = true Game" do
            _(subject.current).must_equal(standing_by1)
          end
        end

        context "GIVEN a Game#on? = true Game doesn't exist" do
          context "GIVEN a recently-ended Game exists" do
            before { recently_ended_game.end_in_victory }

            let(:recently_ended_game) { standing_by1 }

            it "returns the recently-ended Game" do
              _(subject.current).must_equal(recently_ended_game)
            end
          end

          context "GIVEN no recently-ended Game exists" do
            before { standing_by1.set_status_alliance_wins! }

            it "returns nil" do
              _(subject.current).must_be_nil
            end
          end
        end
      end

      describe ".create_for" do
        context "GIVEN a Game.current already exists" do
          it "raises ActiveRecord::RecordNotUnique" do
            _(-> {
              subject.create_for(settings: custom_settings1)
            }).must_raise(ActiveRecord::RecordNotUnique)
          end
        end

        context "GIVEN no Game.current already exists" do
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
            _(-> { subject.start(seed_cell: nil) }).must_change_all([
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
            _(-> { subject.start(seed_cell: nil) }).wont_change_all([
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
        subject { standing_by1.start(seed_cell: nil) }

        it "touches Game#ended_at" do
          _(-> { subject.end_in_victory }).must_change(
            "subject.ended_at",
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_victory }).must_change(
            "subject.status",
            to: Game.status_alliance_wins)
        end

        it "sets Game stats" do
          _(-> { subject.end_in_victory }).must_change_all([
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
          result = subject.end_in_victory
          _(result).must_be_same_as(subject)
          _(@touch_call).must_be_nil
        end
      end
    end

    describe "#end_in_defeat" do
      context "GIVEN a Game that's still on" do
        subject { standing_by1.start(seed_cell: nil) }

        it "touches Game#ended_at" do
          _(-> { subject.end_in_defeat }).must_change(
            "subject.ended_at",
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_defeat }).must_change(
            "subject.status",
            to: Game.status_mines_win)
        end

        it "doesn't set Game stats" do
          _(-> { subject.end_in_defeat }).wont_change_all([
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
          result = subject.end_in_defeat
          _(result).must_be_same_as(subject)
          _(@touch_call).must_be_nil
        end
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
  end
end
