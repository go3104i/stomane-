require 'test_helper'

class DividendsControllerTest < ActionDispatch::IntegrationTest
  test "should get dividend_create" do
    get dividends_dividend_create_url
    assert_response :success
  end

end
