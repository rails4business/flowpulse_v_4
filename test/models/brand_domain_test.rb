require "test_helper"

class BrandDomainTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "brand-domains@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Brand Domains", visibility: "private")
    @brand = @profile.ports.create!(name: "Brand Root", port_kind: :brand, visibility: :draft)
    @map_port = @profile.ports.create!(name: "Map Child", port_kind: :map_port, visibility: :draft)
  end

  test "is valid for a brand port with default modes" do
    domain = BrandDomain.new(brand_port: @brand, host: "www.posturacorretta.org")

    assert domain.valid?
    assert_equal "it", domain.locale
    assert_nil domain.home_page_key
  end

  test "normalizes locale as free string" do
    domain = BrandDomain.create!(
      brand_port: @brand,
      host: "locale.example.org",
      locale: "PT-BR"
    )

    assert_equal "pt-br", domain.locale
  end

  test "normalizes www host to bare domain but keeps other subdomains distinct" do
    bare = BrandDomain.create!(
      brand_port: @brand,
      host: "WWW.PosturaCorretta.org"
    )

    old = BrandDomain.create!(
      brand_port: @brand,
      host: "old.posturacorretta.org",
      locale: "en"
    )

    assert_equal "posturacorretta.org", bare.host
    assert_equal "old.posturacorretta.org", old.host
  end

  test "requires brand_port to be an actual brand" do
    domain = BrandDomain.new(brand_port: @map_port, host: "map.example.org")

    assert_not domain.valid?
    assert_includes domain.errors[:brand_port], "must be a brand port"
  end

  test "validates structured theme colors as hex" do
    domain = BrandDomain.new(
      brand_port: @brand,
      host: "theme.example.org",
      header_bg_color: "blue"
    )

    assert_not domain.valid?
    assert_includes domain.errors[:header_bg_color], "is invalid"
  end

  test "only one primary domain remains per brand" do
    first = BrandDomain.create!(
      brand_port: @brand,
      host: "first.example.org",
      primary: true
    )

    second = BrandDomain.create!(
      brand_port: @brand,
      host: "second.example.org",
      primary: true
    )

    assert_not first.reload.primary?
    assert second.reload.primary?
  end

  test "allows only known home page keys" do
    domain = BrandDomain.new(
      brand_port: @brand,
      host: "home.example.org",
      home_page_key: "not_existing_home"
    )

    assert_not domain.valid?
    assert_includes domain.errors[:home_page_key], "is not included in the list"
  end
end
