import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "slug", "colorPicker", "colorText"]

  connect() {
    this.slugEdited = this.slugTarget.value.trim().length > 0
    this.syncColorText()
  }

  syncSlug() {
    if (this.slugEdited) return

    this.slugTarget.value = this.slugify(this.nameTarget.value)
  }

  markSlugAsEdited() {
    this.slugEdited = this.slugTarget.value.trim().length > 0
  }

  syncColorText() {
    if (!this.hasColorPickerTarget || !this.hasColorTextTarget) return

    this.colorTextTarget.value = this.colorPickerTarget.value.toLowerCase()
  }

  syncColorPicker() {
    if (!this.hasColorPickerTarget || !this.hasColorTextTarget) return

    const normalized = this.normalizeHex(this.colorTextTarget.value)
    if (!normalized) return

    this.colorPickerTarget.value = normalized
    this.colorTextTarget.value = normalized
  }

  normalizeColorText() {
    if (!this.hasColorTextTarget) return

    const normalized = this.normalizeHex(this.colorTextTarget.value)
    if (!normalized) {
      this.syncColorText()
      return
    }

    this.colorPickerTarget.value = normalized
    this.colorTextTarget.value = normalized
  }

  slugify(value) {
    return value
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
  }

  normalizeHex(value) {
    const cleaned = value.trim().toLowerCase()
    const withHash = cleaned.startsWith("#") ? cleaned : `#${cleaned}`

    return /^#(?:[0-9a-f]{6})$/.test(withHash) ? withHash : null
  }
}
