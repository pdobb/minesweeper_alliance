# frozen_string_literal: true

require "test_helper"

class Game::TypeTest < ActiveSupport::TestCase
  let(:unit_class) { Game::Type }

  let(:bestable_game_type1) {
    [
      Game::BEGINNER_TYPE,
      Game::INTERMEDIATE_TYPE,
      Game::EXPERT_TYPE,
    ].sample
  }
  let(:non_bestable_game_type1) {
    [
      Game::CUSTOM_TYPE,
      Game::PATTERN_TYPE,
    ].sample
  }

  describe ".validate_bestable" do
    subject { unit_class }

    given "a bestable Game type" do
      it "returns nil" do
        _(subject.validate_bestable(bestable_game_type1)).must_be_nil
      end
    end

    given "a non-bestable Game type" do
      it "raises TypeError" do
        exception =
          _(-> {
            subject.validate_bestable(non_bestable_game_type1)
          }).must_raise(TypeError)

        _(exception.message).must_equal(
          "bests not available for Game type "\
          "#{non_bestable_game_type1.inspect}")
      end
    end
  end

  describe ".bestable?" do
    subject { unit_class }

    given "a bestable Game type" do
      it "returns true" do
        _(subject.bestable?(bestable_game_type1)).must_equal(true)
      end
    end

    given "a non-bestable Game type" do
      it "returns false" do
        _(subject.bestable?(non_bestable_game_type1)).must_equal(false)
      end
    end
  end
end
