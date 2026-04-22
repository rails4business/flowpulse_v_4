require "test_helper"

class Creator::PortsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "traveler-ports@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Traveler Test", visibility: "private")

    sign_in_as(@user)
  end

  test "new is blocked without manual creator approval" do
    get new_creator_port_path, params: { x: 284, y: 99 }, headers: { "Turbo-Frame" => "port_modal" }

    assert_redirected_to dashboard_path
  end

  test "create is blocked without manual creator approval" do
    assert_no_difference("Port.count") do
      post creator_ports_path, params: {
        port: {
          name: "Flowpulse Atlas",
          slug: "flowpulse-atlas",
          port_kind: "website_external",
          description: "Carta di prova",
          x: 284,
          y: 99
        }
      }
    end

    assert_redirected_to dashboard_path
  end

  test "creator with existing brand root cannot create another brand root" do
    @profile.update!(creator_enabled_until: 1.year.from_now)
    @profile.ports.create!(
      name: "Brand Root Uno",
      slug: "brand-root-uno",
      brand_root: true
    )

    assert_no_difference("Port.count") do
      post creator_ports_path, params: {
        port: {
          name: "Brand Root Due",
          slug: "brand-root-due",
          brand_root: "1"
        }
      }
    end

    assert_redirected_to creator_carta_nautica_path(edit: 1)
  end
end
