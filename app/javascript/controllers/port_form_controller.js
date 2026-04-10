import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "slug"]

  connect() {
    this.slugEdited = this.slugTarget.value.trim().length > 0
  }

  syncSlug() {
    if (this.slugEdited) return

    this.slugTarget.value = this.slugify(this.nameTarget.value)
  }

  markSlugAsEdited() {
    this.slugEdited = this.slugTarget.value.trim().length > 0
  }

  slugify(value) {
    return value
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
  }
}
