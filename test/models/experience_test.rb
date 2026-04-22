require "test_helper"

class ExperienceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "experiences-model@example.com", password: "password")
    @profile = @user.create_profile!(display_name: "Experiences Model", visibility: "private")
    @port = @profile.ports.create!(name: "Port Base", port_kind: :web_app)
  end

  test "slug is derived from name when omitted" do
    experience = @port.experiences.create!(name: "Lezione base", experience_kind: :lesson)

    assert_equal "lezione-base", experience.slug
  end

  test "slug is unique inside the same port" do
    @port.experiences.create!(name: "Lezione base", experience_kind: :lesson, slug: "lezione-base")
    experience = @port.experiences.new(name: "Lezione nuova", experience_kind: :video, slug: "lezione-base")

    assert_not experience.valid?
    assert_includes experience.errors[:slug], "has already been taken"
  end

  test "parent experience must belong to the same port" do
    parent = @port.experiences.create!(name: "Parent", experience_kind: :lesson)
    other_port = @profile.ports.create!(name: "Altro Port", port_kind: :web_app)
    experience = other_port.experiences.new(name: "Child", experience_kind: :quiz, parent_experience: parent)

    assert_not experience.valid?
    assert_includes experience.errors[:parent_experience_id], "must belong to the same port"
  end

  test "supports editorial and program kinds" do
    experience = @port.experiences.create!(name: "Corso Base", experience_kind: :course)

    assert_equal "course", experience.experience_kind
  end
end
