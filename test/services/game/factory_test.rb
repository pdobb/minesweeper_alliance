# frozen_string_literal: true

require "test_helper"

class Game::FactoryTest < ActiveSupport::TestCase
  let(:standing_by1) { games(:standing_by1) }
  let(:custom_settings1) { Board::Settings[6, 6, 4] }

  describe ".create_for" do
    subject { Game::Factory }

    given "a current Game already exists" do
      it "raises ActiveRecord::RecordNotUnique" do
        _(-> {
          subject.create_for(settings: custom_settings1)
        }).must_raise(ActiveRecord::RecordNotUnique)
      end
    end

    given "no current Game" do
      before { standing_by1.delete }

      it "returns a persisted Game with the expected attributes" do
        result = subject.create_for(settings: custom_settings1)

        _(result).must_be_instance_of(Game)
        _(result.persisted?).must_equal(true)
        _(result.status_standing_by?).must_equal(true)
        _(result.board).must_be_instance_of(Board)
        _(result.board.cells.sample).must_be_instance_of(Cell)
      end

      given "an unexpected failure between Game/Board Save and "\
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
    subject { Game::Factory }

    it "orchestrates building of the expected object graph and returns "\
       "the new Game" do
      result = subject.build_for(settings: custom_settings1)

      _(result).must_be_instance_of(Game)
      _(result.board).must_be_instance_of(Board)
      _(result.board.cells).must_be_empty
    end
  end

  ErrorDouble = Class.new(StandardError)
end
