require "test_helper"

class StationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "stations-model@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Stations Model", visibility: "private")
    @port = @profile.ports.create!(name: "Port Base", port_kind: :web_app)
    @line_one = @port.lines.create!(name: "Linea Uno", line_kind: :trail)
    @line_two = @port.lines.create!(name: "Linea Due", line_kind: :blog)
    @experience_one = @port.experiences.create!(name: "Experience Uno", experience_kind: :lesson)
    @experience_two = @port.experiences.create!(name: "Experience Due", experience_kind: :exercise)
  end

  test "slug is derived from name when omitted" do
    station = @line_one.stations.create!(name: "Ingresso", station_kind: :step, experience: @experience_one)

    assert_equal "ingresso", station.slug
  end

  test "link station must point to another line" do
    other_station = @line_one.stations.create!(name: "Tappa Base", station_kind: :step, experience: @experience_one)
    station = @line_one.stations.new(name: "Snodo", station_kind: :branch, experience: @experience_two, link_station: other_station)

    assert_not station.valid?
    assert_includes station.errors[:link_station_id], "must point to a station in another line"
  end

  test "link station can point to another line of the same port" do
    other_station = @line_two.stations.create!(name: "Tappa Due", station_kind: :step, experience: @experience_two)
    station = @line_one.stations.new(name: "Snodo", station_kind: :branch, experience: @experience_one, link_station: other_station)

    assert station.valid?
  end

  test "map coordinates must be integers when present" do
    station = @line_one.stations.new(
      name: "Snodo Visuale",
      station_kind: :step,
      experience: @experience_one,
      map_x: 120.5,
      map_y: "north"
    )

    assert_not station.valid?
    assert_includes station.errors[:map_x], "must be an integer"
    assert_includes station.errors[:map_y], "is not a number"
  end
end
