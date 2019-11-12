require 'test_helper'

class GameControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get game_top_url
    assert_response :success
  end

end
