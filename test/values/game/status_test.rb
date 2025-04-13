# frozen_string_literal: true

require "test_helper"

class Game::StatusTest < ActiveSupport::TestCase
  let(:new_game) { Game.new }
  let(:win1) { games(:win1) }
  let(:loss1) { games(:loss1) }
  let(:standing_by1) { games(:standing_by1) }

  describe ".on?" do
    let(:game1) { new_game }

    subject { Game::Status }

    given "Game#status_standing_by? = true" do
      it "returns true" do
        _(subject.on?(game1)).must_equal(true)
      end
    end

    given "Game#status_sweep_in_progress? = true" do
      before { game1.set_status_sweep_in_progress }

      it "returns true" do
        _(subject.on?(game1)).must_equal(true)
      end
    end

    given "Game#status_alliance_wins? = true" do
      before { game1.set_status_alliance_wins }

      it "returns false" do
        _(subject.on?(game1)).must_equal(false)
      end
    end

    given "Game#status_mines_win? = true" do
      before { game1.set_status_mines_win }

      it "returns false" do
        _(subject.on?(game1)).must_equal(false)
      end
    end
  end

  describe ".over?" do
    let(:game1) { new_game }

    subject { Game::Status }

    given "Game#status_standing_by? = true" do
      it "returns false" do
        _(subject.over?(game1)).must_equal(false)
      end
    end

    given "Game#status_sweep_in_progress? = true" do
      before { game1.set_status_sweep_in_progress }

      it "returns false" do
        _(subject.over?(game1)).must_equal(false)
      end
    end

    given "Game#status_alliance_wins? = true" do
      before { game1.set_status_alliance_wins }

      it "returns false" do
        _(subject.over?(game1)).must_equal(true)
      end
    end

    given "Game#status_mines_win? = true" do
      before { game1.set_status_mines_win }

      it "returns false" do
        _(subject.over?(game1)).must_equal(true)
      end
    end
  end

  describe ".ended_in_victory?" do
    subject { Game::Status }

    given "Game#status_alliance_wins? = true" do
      let(:game1) { win1 }

      it "returns true" do
        _(subject.ended_in_victory?(game1)).must_equal(true)
      end
    end

    given "Game#status_alliance_wins? = false'" do
      let(:game1) { [loss1, standing_by1].sample }

      it "returns false" do
        _(subject.ended_in_victory?(game1)).must_equal(false)
      end
    end
  end

  describe ".ended_in_defeat?" do
    subject { Game::Status }

    given "Game#status_mines_win? == true" do
      let(:game1) { loss1 }

      it "returns true" do
        _(subject.ended_in_defeat?(game1)).must_equal(true)
      end
    end

    given "Game#status_mines_win? == false" do
      let(:game1) { [win1, standing_by1].sample }

      it "returns false" do
        _(subject.ended_in_defeat?(game1)).must_equal(false)
      end
    end
  end
end
