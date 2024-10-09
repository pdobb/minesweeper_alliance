# frozen_string_literal: true

require "test_helper"

class CurrentUserTest < ActiveSupport::TestCase
  describe "CurrentUser" do
    let(:unit_class) { CurrentUser }

    let(:user1) { users(:user1) }

    describe "#call" do
      context "GIVEN a stored User Token" do
        subject { unit_class.new(context: ContextDouble.new(user_token:)) }

        context "GIVEN a User exists for the User Token" do
          let(:user_token) { user1.id }

          it "returns the expected User" do
            _(subject.call).must_equal(user1)
          end
        end

        context "GIVEN no User exists for the User Token" do
          let(:user_token) { "UNKNOWN_USER_TOKEN" }

          it "creates a new User, and returns it" do
            result =
              _(-> { subject.call }).must_change(
                "User.count", to: User.count.next)
            _(result).must_be_instance_of(User)
          end
        end
      end
    end

    context "GIVEN no stored User Token" do
      subject { unit_class.new(context: ContextDouble.new) }

      it "creates a new User, and returns it" do
        result =
          _(-> { subject.call }).must_change(
            "User.count", to: User.count.next)
        _(result).must_be_instance_of(User)
      end
    end
  end

  class ContextDouble
    def initialize(cookies = {})
      @cookies = CookieJar.new(cookies)
    end

    def store_http_cookie(name, value:)
    end

    attr_reader :cookies

    class CookieJar
      def initialize(cookies)
        @cookies = cookies
      end

      def [](key) = @cookies[key]

      def []=(key, value)
        @cookies[key] = value
      end

      def permanent = self
    end
  end
end
