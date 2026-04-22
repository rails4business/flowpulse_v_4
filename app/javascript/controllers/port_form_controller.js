import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "slug", "colorPicker", "colorText", "brandRoot", "portKind", "portKindGroup", "brandRootHint", "brandParentInput", "brandParentId"]

  connect() {
    this.previousPortKindValue = this.hasPortKindTarget ? this.portKindTarget.value : null
    this.syncColorText()
    this.syncBrandRootState()
    this.syncSlug()
  }

  syncSlug() {
    this.slugTarget.value = this.slugify(this.nameTarget.value)
  }

  markSlugAsEdited() {
    if (this.slugTarget.value.trim().length === 0) {
      this.syncSlug()
    }
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

  toggleBrandRoot() {
    this.syncBrandRootState()
  }

  syncBrandParent() {
    if (!this.hasBrandParentInputTarget || !this.hasBrandParentIdTarget) return

    const selectedName = this.brandParentInputTarget.value.trim()

    if (selectedName.length === 0) {
      this.brandParentIdTarget.value = ""
      return
    }

    const matchingOption = Array.from(this.brandParentInputTarget.list?.options || []).find((option) => option.value === selectedName)
    this.brandParentIdTarget.value = matchingOption?.dataset.brandId || ""
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

  syncBrandRootState() {
    if (!this.hasBrandRootTarget || !this.hasPortKindGroupTarget || !this.hasPortKindTarget) return

    const brandRootEnabled = this.brandRootTarget.checked

    if (brandRootEnabled) {
      if (this.portKindTarget.value) {
        this.previousPortKindValue = this.portKindTarget.value
      }

      this.portKindTarget.value = ""
      this.portKindGroupTarget.style.visibility = "hidden"
      this.portKindGroupTarget.style.pointerEvents = "none"

      if (this.hasBrandRootHintTarget) {
        this.brandRootHintTarget.innerHTML = "Questo port e' un <strong>brand root</strong>. Dalla mappa apre la sua carta nautica; la modifica principale avviene dal titolo della carta. Se ha un brand padre, viene mostrato come sottobrand nella carta del padre. La tipologia resta vuota."
      }

      if (this.hasBrandParentInputTarget && this.hasBrandParentIdTarget) {
        this.brandParentInputTarget.value = ""
        this.brandParentIdTarget.value = ""
      }

      return
    }

    this.portKindGroupTarget.style.visibility = ""
    this.portKindGroupTarget.style.pointerEvents = ""

    if (this.previousPortKindValue) {
      this.portKindTarget.value = this.previousPortKindValue
    }

    if (this.hasBrandRootHintTarget) {
      this.brandRootHintTarget.innerHTML = "Attiva questa opzione solo se il port deve diventare la radice di una carta brand. Quando e' brand root, la tipologia normale viene nascosta e resta vuota."
    }
  }
}
