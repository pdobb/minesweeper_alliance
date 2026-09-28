# frozen_string_literal: true

require "test_helper"

class InternetNoiseTest < ActionDispatch::IntegrationTest
  describe "GET /up" do
    given "Client-IP disagrees with X-Forwarded-For" do
      let(:headers) {
        {
          # rubocop:disable Style/IpAddresses
          "Client-IP" => "192.0.2.1",
          "X-Forwarded-For" => "198.51.100.1",
          # rubocop:enable Style/IpAddresses
        }
      }

      it "responds successfully" do
        get("/up", headers:)

        _(response.status).must_equal(200)
      end
    end
  end

  describe "GET /manifest" do
    it "returns the JSON manifest" do
      get("/manifest")

      _(response.status).must_equal(200)
      _(response.media_type).must_equal("application/json")
    end

    given "the client asks for JavaScript" do
      let(:headers) { { "Accept" => "text/javascript" } }

      it "still returns the JSON manifest" do
        get("/manifest", headers:)

        _(response.status).must_equal(200)
        _(response.media_type).must_equal("application/json")
      end
    end

    it "does not treat /manifest.js as an application error" do
      get("/manifest.js")

      _(response.status).must_equal(404)
    end

    it "still serves /manifest.json" do
      get("/manifest.json")

      _(response.status).must_equal(200)
      _(response.media_type).must_equal("application/json")
    end
  end

  describe "GET /service-worker" do
    given "the client asks for HTML" do
      let(:headers) { { "Accept" => "text/html" } }

      it "returns the JavaScript worker" do
        get("/service-worker", headers:)

        _(response.status).must_equal(200)
        _(response.media_type).must_equal("text/javascript")
      end
    end
  end
end
