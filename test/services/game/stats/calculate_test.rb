# frozen_string_literal: true

require "test_helper"

class Game::Stats::CalculateTest < ActiveSupport::TestCase
  let(:win1) { games(:win1) }

  describe ".call" do
    subject { Game::Stats::Calculate }

    it "sets the expected values on the associated Game" do
      result =
        _(-> { subject.call(win1) }).must_change_all([
          ["win1.score", from: nil, to: 30.0],
          ["win1.bbbv", from: nil],
          ["win1.bbbvps", from: nil],
          ["win1.efficiency", from: nil, to: 0.2],
        ])
      _(result).must_equal(true)
    end
  end
end
