require "test_helper"

class CreatorControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "traveler-captain@example.com", password: "password")
    @user.create_profile!(
      display_name: "Captain",
      visibility: "private"
    )

    sign_in_as(@user)
  end

  test "carta nautica is blocked for a user without manual creator approval" do
    get creator_carta_nautica_path, params: { add_port: true, x: 200, y: 140 }

    assert_redirected_to dashboard_path
  end
end
