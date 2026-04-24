require "test_helper"

class StationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "stations-model@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Stations Model", visibility: "private")
    @port = @profile.ports.create!(name: "Port Base", port_kind: :web_app)
    @line_one = @port.lines.create!(name: "Linea Uno", line_kind: :trail)
    @line_two = @port.lines.create!(name: "Linea Due", line_kind: :route)
    @experience_one = @port.experiences.create!(name: "Experience Uno", experience_kind: :lesson)
    @experience_two = @port.experiences.create!(name: "Experience Due", experience_kind: :exercise)
  end

  test "slug is derived from name when omitted" do
    station = @line_one.stations.create!(name: "Ingresso", station_kind: :normal, experience: @experience_one)

    assert_equal "ingresso", station.slug
  end

  test "link station must point to another line" do
    other_station = @line_one.stations.create!(name: "Tappa Base", station_kind: :normal, experience: @experience_one)
    station = @line_one.stations.new(name: "Snodo", station_kind: :branch, experience: @experience_two, link_station: other_station)

    assert_not station.valid?
    assert_includes station.errors[:link_station_id], "must point to a station in another line"
  end

  test "link station can point to another line of the same port" do
    other_station = @line_two.stations.create!(name: "Tappa Due", station_kind: :normal, experience: @experience_two)
    station = @line_one.stations.new(name: "Snodo", station_kind: :branch, link_station: other_station)

    assert station.valid?
  end

  test "connector station must not have its own experience" do
    other_station = @line_two.stations.create!(name: "Tappa Due", station_kind: :normal, experience: @experience_two)
    station = @line_one.stations.new(name: "Snodo", station_kind: :branch, experience: @experience_one, link_station: other_station)

    assert_not station.valid?
    assert_includes station.errors[:experience_id], "must be empty for connector stations"
  end

  test "primary station must have an experience" do
    station = @line_one.stations.new(name: "Ingresso", station_kind: :normal)

    assert_not station.valid?
    assert_includes station.errors[:experience], "must exist for primary stations"
  end

  test "connector station resolves canonical experience from primary station" do
    other_station = @line_two.stations.create!(name: "Tappa Due", station_kind: :normal, experience: @experience_two)
    station = @line_one.stations.create!(name: "Snodo", station_kind: :branch, link_station: other_station)

    assert station.connector?
    assert_equal other_station, station.primary_station
    assert_equal @experience_two, station.canonical_experience
  end

  test "map coordinates must be integers when present" do
    station = @line_one.stations.new(
      name: "Snodo Visuale",
      station_kind: :normal,
      experience: @experience_one,
      map_x: 120.5,
      map_y: "north"
    )

    assert_not station.valid?
    assert_includes station.errors[:map_x], "must be an integer"
    assert_includes station.errors[:map_y], "is not a number"
  end

  test "port entry defaults to false and can be enabled" do
    station = @line_one.stations.create!(name: "Ingresso Port", station_kind: :normal, experience: @experience_one)

    assert_not station.port_entry?

    station.update!(port_entry: true)

    assert station.reload.port_entry?
  end

  test "shared group controls default to neutral values" do
    station = @line_one.stations.create!(name: "Nodo Gruppo", station_kind: :normal, experience: @experience_one)

    assert_equal 0, station.link_order
    assert_equal "horizontal", station.shared_group_angle
  end

  test "single station is both opening and closing by position" do
    station = @line_one.stations.create!(name: "Nodo Base", station_kind: :normal, experience: @experience_one)

    assert station.opening?
    assert station.closing?
  end
end
