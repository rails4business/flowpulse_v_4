import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { defaultTab: String }

  connect() {
    const initialTab = this.defaultTabValue || this.tabTargets[0]?.dataset.tabId
    if (initialTab) this.activate(initialTab)
  }

  switch(event) {
    event.preventDefault()
    this.activate(event.currentTarget.dataset.tabId)
  }

  activate(tabId) {
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tabId === tabId
      tab.classList.toggle("active", active)
      tab.setAttribute("aria-selected", active)
    })

    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.tabId === tabId
      panel.hidden = !active
    })
  }
}
