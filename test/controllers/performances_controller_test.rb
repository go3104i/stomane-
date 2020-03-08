require 'test_helper'

class PerformancesControllerTest < ActionDispatch::IntegrationTest
  test "should get liquidation_update" do
    get performances_liquidation_update_url
    assert_response :success
  end

end
