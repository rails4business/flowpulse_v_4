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
      port_kind: :web_app
    )

    assert_equal "atlante-del-mare", port.slug
  end

  test "coordinates must be integers when present" do
    port = @profile.ports.new(
      name: "Coordinate Test",
      slug: "coordinate-test",
      port_kind: :youtube,
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
      port_kind: :web_app,
      brand_root: true,
      color_key: "#dc2626"
    )

    child = @profile.ports.create!(
      name: "Website Figlio",
      port_kind: :website_external,
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
      port_kind: :web_app,
      color_key: "rosso"
    )

    assert_not port.valid?
    assert_includes port.errors[:color_key], "is invalid"
  end

  test "inherits brand port from source brand context" do
    brand = @profile.ports.create!(
      name: "Brand Madre",
      port_kind: :web_app,
      brand_root: true
    )

    branch = @profile.ports.create!(
      name: "Nodo Figlio",
      port_kind: :website_external,
      brand_port: brand
    )

    assert_equal brand, brand.inherited_brand_port
    assert_equal brand, branch.inherited_brand_port
  end

  test "brand root can keep port kind empty" do
    port = @profile.ports.new(
      name: "Canale non valido",
      slug: "canale-non-valido",
      brand_root: true
    )

    assert port.valid?
    port.validate
    assert_nil port.port_kind
  end

  test "non brand root requires port kind" do
    port = @profile.ports.new(
      name: "Porto senza tipo",
      slug: "porto-senza-tipo",
      brand_root: false
    )

    assert_not port.valid?
    assert_includes port.errors[:port_kind], "can't be blank"
  end

  test "webapp sea chart yaml is parsed into json" do
    port = @profile.ports.create!(
      name: "Mappa Webapp",
      port_kind: :web_app,
      webapp_sea_chart_yaml: <<~YAML
        entry: postura
        nodes:
          postura:
            label: Postura
            x: 450
            y: 230
      YAML
    )

    assert_equal "postura", port.webapp_sea_chart["entry"]
    assert_equal 450, port.webapp_sea_chart.dig("nodes", "postura", "x")
  end

  test "invalid webapp sea chart yaml adds an error" do
    port = @profile.ports.new(
      name: "Mappa Non Valida",
      port_kind: :web_app,
      webapp_sea_chart_yaml: "nodes: ["
    )

    assert_not port.valid?
    assert_includes port.errors[:webapp_sea_chart_yaml].first, "is not valid YAML"
  end
end
