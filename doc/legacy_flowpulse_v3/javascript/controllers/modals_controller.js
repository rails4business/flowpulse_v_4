import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modals"
export default class extends Controller {
  connect() {
    this.boundHandleClick = this.handleClick.bind(this)
    this.element.addEventListener("click", this.boundHandleClick)
  }

  disconnect() {
    this.element.removeEventListener("click", this.boundHandleClick)
  }

  handleClick(event) {
    const opener = event.target.closest("[data-modal-open]")
    if (opener) {
      event.preventDefault()
      this.open(opener.dataset.modalOpen)
      return
    }

    const closer = event.target.closest("[data-modal-close]")
    if (closer) {
      event.preventDefault()
      this.close(closer.dataset.modalClose)
    }
  }

  open(id) {
    const modal = document.querySelector(`[data-modal="${id}"]`)
    if (!modal) return
    modal.classList.remove("hidden")
    modal.classList.add("flex")
  }

  close(id) {
    const modal = document.querySelector(`[data-modal="${id}"]`)
    if (!modal) return
    modal.classList.add("hidden")
    modal.classList.remove("flex")
  }
}
