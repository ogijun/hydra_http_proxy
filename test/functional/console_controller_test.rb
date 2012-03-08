require 'test_helper'

class ConsoleControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get put_bundle" do
    get :put_bundle
    assert_response :success
  end

  test "should get get_result" do
    get :get_result
    assert_response :success
  end

end
