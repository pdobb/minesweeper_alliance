# frozen_string_literal: true

require "test_helper"

class AppTest < ActiveSupport::TestCase
  describe ".introspect" do
    subject { App }

    it "returns the expected Hash" do
      result = subject.introspect

      _(result).must_be_instance_of(Hash)
      _(result.slice(:name, :created_at, :env, :debug_mode)).must_equal({
        name: "Minesweeper Alliance",
        created_at: Time.zone.local(2024, 8, 9),
        env: "test",
        debug_mode: false,
      })
    end
  end

  describe ".created_at" do
    subject { App }

    it "returns the expected Time" do
      result = App.created_at

      _(result.year).must_equal(2024)
      _(result.month).must_equal(8)
      _(result.day).must_equal(9)
    end
  end

  describe ".debug?" do
    subject { App }

    given "Rails.configuration.debug = true" do
      before { MuchStub.spy(Rails, :configuration, debug: true) }

      it "returns true" do
        _(subject.debug?).must_equal(true)
      end
    end

    given "Rails.configuration.debug = false" do
      before { MuchStub.spy(Rails, :configuration, debug: false) }

      it "returns false" do
        _(subject.debug?).must_equal(false)
      end
    end
  end

  describe ".test?" do
    subject { App }

    given "Rails.env.test? = true" do
      before { MuchStub.spy(Rails, :env, test?: true) }

      it "returns true" do
        _(subject.test?).must_equal(true)
      end
    end

    given "Rails.env.test? = false" do
      before { MuchStub.spy(Rails, :env, test?: false) }

      it "returns false" do
        _(subject.test?).must_equal(false)
      end
    end
  end

  describe ".development?" do
    subject { App }

    given "Rails.env.development? = true" do
      before { MuchStub.spy(Rails, :env, development?: true) }

      it "returns true" do
        _(subject.development?).must_equal(true)
      end
    end

    given "Rails.env.development? = false" do
      before { MuchStub.spy(Rails, :env, development?: false) }

      it "returns false" do
        _(subject.development?).must_equal(false)
      end
    end
  end

  describe ".production?" do
    subject { App }

    given "Rails.env.production? = true" do
      before { MuchStub.spy(Rails, :env, production?: true) }

      it "returns true" do
        _(subject.production?).must_equal(true)
      end
    end

    given "Rails.env.production? = false" do
      before { MuchStub.spy(Rails, :env, production?: false) }

      it "returns false" do
        _(subject.production?).must_equal(false)
      end
    end
  end
end
