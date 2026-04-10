import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  connect() {
    this.syncWithViewport()
    this.handleResize = this.syncWithViewport.bind(this)
    this.handleKeydown = this.onKeydown.bind(this)
    window.addEventListener("resize", this.handleResize)
    window.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    window.removeEventListener("keydown", this.handleKeydown)
    document.body.classList.remove("sidebar-open")
  }

  open() {
    if (!this.mobileViewport()) return

    this.element.classList.add("is-open")
    document.body.classList.add("sidebar-open")
  }

  close() {
    if (!this.mobileViewport()) return

    this.element.classList.remove("is-open")
    document.body.classList.remove("sidebar-open")
  }

  syncWithViewport() {
    if (!this.mobileViewport()) {
      this.element.classList.remove("is-open")
      document.body.classList.remove("sidebar-open")
    }
  }

  mobileViewport() {
    return window.innerWidth <= 960
  }

  onKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
