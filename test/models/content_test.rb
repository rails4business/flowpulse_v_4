require "test_helper"

class ContentTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "content-model@example.com", password: "password")
    @profile = @user.create_profile!(
      display_name: "Content Model",
      visibility: "private"
    )
    @port = @profile.ports.create!(
      name: "Porta Contenuto",
      port_kind: :web_app
    )
  end

  test "display title and slug fall back to the contentable" do
    content = Content.create!(
      contentable: @port,
      visibility: :draft
    )

    assert_equal @port.name, content.display_title
    assert_equal @port.slug, content.display_slug
  end

  test "port can have one primary content" do
    content = Content.create!(
      contentable: @port,
      visibility: :draft
    )

    assert_equal content, @port.reload.content
  end
end
