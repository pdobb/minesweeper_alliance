# frozen_string_literal: true

require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get bad_request" do
    get("/400")

    assert_response(:bad_request)
  end

  test "should get not_found" do
    get("/404")

    assert_response(:not_found)
  end

  test "should get not_acceptable" do
    get("/406")

    assert_response(:not_acceptable)
  end

  test "should get :unprocessable_content" do
    get("/422")

    assert_response(:unprocessable_content)
  end

  test "should get internal_server_error" do
    get("/500")

    assert_response(:internal_server_error)
  end
end
