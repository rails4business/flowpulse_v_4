require "test_helper"

class LineTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "lines-model@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Lines Model", visibility: "private")
    @port = @profile.ports.create!(name: "Port Base", port_kind: :web_app)
  end

  test "slug is derived from name when omitted" do
    line = @port.lines.create!(name: "Percorso Base", line_kind: :trail)

    assert_equal "percorso-base", line.slug
  end

  test "slug is unique inside the same port" do
    @port.lines.create!(name: "Percorso Base", line_kind: :trail, slug: "percorso-base")
    line = @port.lines.new(name: "Percorso Base 2", line_kind: :route, slug: "percorso-base")

    assert_not line.valid?
    assert_includes line.errors[:slug], "has already been taken"
  end
end
