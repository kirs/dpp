require 'test_helper'

class DppControllerTest < ActionController::TestCase
  test "should get find" do
    get :find
    assert_response :success
  end

  test "should get results" do
    get :results
    assert_response :success
  end

end
