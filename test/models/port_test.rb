require "test_helper"

class PortTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "ports-model@example.com", password: "password")
    @profile = @user.create_profile!(
      display_name: "Ports Model",
      visibility: "private"
    )
  end

  test "slug is derived from name when omitted" do
    port = @profile.ports.create!(
      name: "Atlante del Mare",
      port_kind: :brand,
      visibility: :draft
    )

    assert_equal "atlante-del-mare", port.slug
  end

  test "coordinates must be integers when present" do
    port = @profile.ports.new(
      name: "Coordinate Test",
      slug: "coordinate-test",
      port_kind: :blog,
      visibility: :draft,
      x: 12.5,
      y: "north"
    )

    assert_not port.valid?
    assert_includes port.errors[:x], "must be an integer"
    assert_includes port.errors[:y], "is not a number"
  end

  test "color key defaults from port kind and can be inherited by brand ring" do
    brand = @profile.ports.create!(
      name: "Brand Madre",
      port_kind: :brand,
      visibility: :draft,
      color_key: "#dc2626"
    )

    child = @profile.ports.create!(
      name: "Mappa Figlia",
      port_kind: :map_port,
      visibility: :draft,
      brand_port: brand,
      color_key: "#2563eb"
    )

    assert_equal "#dc2626", brand.color_key
    assert_equal "#2563eb", child.color_config[:stroke]
    assert_equal "#dc2626", child.brand_ring_color_config[:stroke]
  end

  test "color key must be a hex color" do
    port = @profile.ports.new(
      name: "Color Test",
      slug: "color-test",
      port_kind: :brand,
      visibility: :draft,
      color_key: "rosso"
    )

    assert_not port.valid?
    assert_includes port.errors[:color_key], "is invalid"
  end

  test "inherits brand port from source brand context" do
    brand = @profile.ports.create!(
      name: "Brand Madre",
      port_kind: :brand,
      visibility: :draft
    )

    branch = @profile.ports.create!(
      name: "Nodo Figlio",
      port_kind: :map_port,
      visibility: :draft,
      brand_port: brand
    )

    assert_equal brand, brand.inherited_brand_port
    assert_equal brand, branch.inherited_brand_port
  end
end
