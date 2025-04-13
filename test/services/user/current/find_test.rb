# frozen_string_literal: true

require "test_helper"

class User::Current::FindTest < ActiveSupport::TestCase
  let(:user1) { users(:user1) }

  describe "#call" do
    given "a stored User Token" do
      subject {
        User::Current::Find.new(
          context: ContextDouble.new(User::Current::COOKIE => user_token))
      }

      given "a User exists for the User Token" do
        let(:user_token) { user1.id }

        it "returns the expected User" do
          _(subject.call).must_equal(user1)
        end
      end

      given "no User exists for the User Token" do
        let(:user_token) { "UNKNOWN_USER_TOKEN" }

        it "builds a new Guest, and returns it" do
          _(subject.call).must_be_instance_of(Guest)
        end
      end
    end
  end

  given "no stored User Token" do
    subject { User::Current::Find.new(context: ContextDouble.new) }

    it "builds a new Guest, and returns it" do
      _(subject.call).must_be_instance_of(Guest)
    end
  end
end

class ContextDouble
  def initialize(cookies = {})
    @cookies = CookieJar.new(cookies)
  end

  def store_signed_cookie(...) = nil
  def user_agent = "TEST_USER_AGENT"

  attr_reader :cookies

  class CookieJar
    def initialize(cookies)
      @cookies = cookies
    end

    def [](key) = @cookies[key]

    def []=(key, value)
      @cookies[key] = value
    end

    def signed = self
    def permanent = self
  end
end
