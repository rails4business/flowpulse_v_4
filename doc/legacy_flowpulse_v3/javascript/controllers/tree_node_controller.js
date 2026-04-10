import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["children", "icon"]

  connect() {
    // Debug: così vedi in console se si attacca
    console.log("TreeNodeController connected for", this.element)
  }

  toggle(event) {
    event.preventDefault()

    if (!this.hasChildrenTarget) return

    this.childrenTarget.classList.toggle("hidden")

    if (this.hasIconTarget) {
      const isHidden = this.childrenTarget.classList.contains("hidden")
      this.iconTarget.textContent = isHidden ? "▶" : "▼"
    }
  }
}
