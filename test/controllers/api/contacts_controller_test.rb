require "test_helper"

class Api::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get resolve_contact" do
    get api_contacts_resolve_contact_url
    assert_response :success
  end
end
