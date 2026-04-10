import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    if (!this.hasDialogTarget) return
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
  }

  close() {
    this.navigateBackToChart()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.navigateBackToChart()
  }

  closeOnCancel(event) {
    event.preventDefault()
    this.navigateBackToChart()
  }

  navigateBackToChart() {
    if (window.Turbo) {
      window.Turbo.visit("/creator/carta_nautica")
      return
    }

    window.location.href = "/creator/carta_nautica"
  }
}
