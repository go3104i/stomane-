require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get account_info" do
    get users_account_info_url
    assert_response :success
  end

end
