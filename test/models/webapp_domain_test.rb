require "test_helper"

class WebappDomainTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "brand-domains@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Brand Domains", visibility: "private")
    @web_app_port = @profile.ports.create!(name: "Web App Port", port_kind: :web_app)
    @map_port = @profile.ports.create!(name: "Map Child", port_kind: :website_external)
  end

  test "is valid for a web app port with default modes" do
    domain = WebappDomain.new(brand_port: @web_app_port, host: "www.posturacorretta.org")

    assert domain.valid?
    assert_equal "it", domain.locale
    assert_nil domain.home_page_key
  end

  test "normalizes locale as free string" do
    domain = WebappDomain.create!(
      brand_port: @web_app_port,
      host: "locale.example.org",
      locale: "PT-BR"
    )

    assert_equal "pt-br", domain.locale
  end

  test "normalizes www host to bare domain but keeps other subdomains distinct" do
    bare = WebappDomain.create!(
      brand_port: @web_app_port,
      host: "WWW.PosturaCorretta.org"
    )

    old = WebappDomain.create!(
      brand_port: @web_app_port,
      host: "old.posturacorretta.org",
      locale: "en"
    )

    assert_equal "posturacorretta.org", bare.host
    assert_equal "old.posturacorretta.org", old.host
  end

  test "requires brand_port to be a web app port" do
    domain = WebappDomain.new(brand_port: @map_port, host: "map.example.org")

    assert_not domain.valid?
    assert_includes domain.errors[:brand_port], "must be a web app port"
  end

  test "validates structured theme colors as hex" do
    domain = WebappDomain.new(
      brand_port: @web_app_port,
      host: "theme.example.org",
      header_bg_color: "blue"
    )

    assert_not domain.valid?
    assert_includes domain.errors[:header_bg_color], "is invalid"
  end

  test "only one primary domain remains per brand" do
    first = WebappDomain.create!(
      brand_port: @web_app_port,
      host: "first.example.org",
      primary: true
    )

    second = WebappDomain.create!(
      brand_port: @web_app_port,
      host: "second.example.org",
      primary: true,
      locale: "en"
    )

    assert_not first.reload.primary?
    assert second.reload.primary?
  end

  test "allows only known home page keys" do
    domain = WebappDomain.new(
      brand_port: @web_app_port,
      host: "home.example.org",
      home_page_key: "not_existing_home"
    )

    assert_not domain.valid?
    assert_includes domain.errors[:home_page_key], "is not included in the list"
  end
end
