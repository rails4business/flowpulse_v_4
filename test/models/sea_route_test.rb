require "test_helper"

class SeaRouteTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "sea-routes@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Sea Routes", visibility: "private")
    @source = @profile.ports.create!(name: "Porto A", port_kind: :web_app, brand_root: true)
    @target = @profile.ports.create!(name: "Porto B", port_kind: :website_external)
  end

  test "keeps route source and target as authored and avoids duplicate exact pairs" do
    first = @profile.sea_routes.create!(source_port: @target, target_port: @source)

    assert_equal @target.id, first.source_port_id
    assert_equal @source.id, first.target_port_id

    duplicated = @profile.sea_routes.new(source_port: @target, target_port: @source)

    assert_not duplicated.valid?
  end

  test "does not allow a duplicate route with reversed endpoints" do
    @profile.sea_routes.create!(source_port: @source, target_port: @target)

    reversed = @profile.sea_routes.new(source_port: @target, target_port: @source)

    assert_not reversed.valid?
    assert_includes reversed.errors[:base], "Sea route già esistente tra questi due porti"
  end

  test "requires distinct ports from the same profile" do
    same_port_route = @profile.sea_routes.new(source_port: @source, target_port: @source)

    assert_not same_port_route.valid?

    other_user = User.create!(email_address: "other-sea-routes@example.com", password: "password")
    other_profile = other_user.create_profile!(display_name: "Other", visibility: "private")
    foreign_port = other_profile.ports.create!(name: "Porto C", port_kind: :youtube)

    foreign_route = @profile.sea_routes.new(source_port: @source, target_port: foreign_port)

    assert_not foreign_route.valid?
  end

  test "defaults to directed route with bidirectional false and assigns a position" do
    route = @profile.sea_routes.create!(source_port: @source, target_port: @target)

    assert_equal false, route.bidirectional
    assert_equal 1, route.position
  end

  test "toggles bidirectional state" do
    route = @profile.sea_routes.create!(source_port: @source, target_port: @target, bidirectional: false)

    route.toggle_bidirectional!
    assert route.reload.bidirectional?

    route.toggle_bidirectional!
    assert_not route.reload.bidirectional?
  end

  test "invert_direction swaps route endpoints and keeps route directed" do
    route = @profile.sea_routes.create!(source_port: @source, target_port: @target, bidirectional: true)

    route.invert_direction!

    assert_equal @target.id, route.reload.source_port_id
    assert_equal @source.id, route.target_port_id
    assert_not route.bidirectional?
  end
end
