import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "title", "meta", "body"]

  open(event) {
    const trigger = event.currentTarget

    this.titleTarget.textContent = trigger.dataset.changelogTitle
    this.metaTarget.textContent = `${trigger.dataset.changelogDate} · ${trigger.dataset.changelogType}`
    this.bodyTarget.textContent = trigger.dataset.changelogBody
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
