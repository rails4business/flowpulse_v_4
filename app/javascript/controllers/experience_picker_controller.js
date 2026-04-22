import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "idField"]
  static values = { options: Array }

  connect() {
    this.syncSearchFromId()
  }

  input() {
    this.syncIdFromSearch()
  }

  change() {
    this.syncIdFromSearch()
  }

  syncSearchFromId() {
    if (!this.hasSearchTarget || !this.hasIdFieldTarget) return
    if (this.searchTarget.value?.trim().length > 0) return

    const selected = this.optionsValue.find((option) => String(option.id) === String(this.idFieldTarget.value))
    if (selected) this.searchTarget.value = selected.name
  }

  syncIdFromSearch() {
    if (!this.hasSearchTarget || !this.hasIdFieldTarget) return

    const query = this.searchTarget.value.trim().toLowerCase()
    const match = this.optionsValue.find((option) => option.name.trim().toLowerCase() === query)
    this.idFieldTarget.value = match ? match.id : ""
  }
}
