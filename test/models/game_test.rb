# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  describe "Game" do
    let(:unit_class) { Game }

    let(:win1) { games(:win1) }
    let(:loss1) { games(:loss1) }
    let(:standing_by1) { games(:standing_by1) }
    let(:new_game) { Game.new }

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

      describe ".build_for" do
        before do
          MuchStub.tap_on_call(Conversions, :DifficultyLevel) { |_value, call|
            @difficulty_level_conversion_function_call = call
          }
        end

        it "orchestrates building of the expected object graph and returns "\
           "the new Game" do
          result = subject.build_for(difficulty_level: "Test")

          _(@difficulty_level_conversion_function_call.pargs).must_equal(
            ["Test"])
          _(result).must_be_instance_of(unit_class)
          _(result.board).must_be_instance_of(Board)
          _(result.board.cells.sample).must_be_instance_of(Cell)
        end
      end
    end

    describe "#difficulty_level" do
      subject { win1 }

      it "returns the expected DifficultyLevel wrapper object" do
        result = subject.difficulty_level
        _(result).must_be_instance_of(DifficultyLevel)
        _(result.name).must_equal(subject.difficulty_level_before_type_cast)
      end
    end

    describe "#start" do
      before do
        MuchStub.on_call(subject.board, :place_mines) { |call|
          @place_mines_call = call
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
          _(@place_mines_call.kargs).must_equal(seed_cell: nil)
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
          _(@place_mines_call).must_be_nil
        end
      end
    end

    describe "#end_in_victory" do
      context "GIVEN a Game that's still on" do
        subject { standing_by1.start(seed_cell: nil) }

        it "touches Game#ended_at" do
          _(-> { subject.end_in_victory }).must_change(
            -> { subject.ended_at },
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_victory }).must_change(
            -> { subject.status },
            to: Game.status_alliance_wins)
        end
      end

      context "GIVEN a Game that's already over" do
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
            -> { subject.ended_at },
            from: nil)
        end

        it "sets the expected Status" do
          _(-> { subject.end_in_defeat }).must_change(
            -> { subject.status },
            to: Game.status_mines_win)
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
  end
end
