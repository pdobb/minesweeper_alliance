# frozen_string_literal: true

require "test_helper"

class Game::StatusTest < ActiveSupport::TestCase
  let(:new_game) { Game.new }

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
end
