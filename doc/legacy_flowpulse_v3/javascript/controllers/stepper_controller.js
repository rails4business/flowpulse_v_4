import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "mobileStep", "content"]

  connect() {
    // Show the first step by default if none is selected
    if (!this.hasSelectedStep) {
      this.select({ params: { index: 0 } })
    }
  }

  select(event) {
    const index = event.params?.index ?? parseInt(event.currentTarget.dataset.index)

    // Update Desktop Stepper
    this.stepTargets.forEach((el, i) => {
      if (i === index) {
        el.setAttribute("aria-current", "step")
      } else {
        el.removeAttribute("aria-current")
      }

      // Handle completion styling (visual flair)
      if (i < index) {
        el.dataset.completed = "true"
      } else {
        delete el.dataset.completed
      }
    })

    // Update Mobile Stepper (Vertical List)
    this.mobileStepTargets.forEach((el, i) => {
      if (i === index) {
        el.classList.add("border-primary", "bg-blue-50/50", "ring-1", "ring-primary/20")
        el.classList.remove("border-slate-200", "bg-white")
        const badge = el.querySelector("div")
        if (badge) {
          badge.classList.add("bg-primary", "text-white", "border-primary")
          badge.classList.remove("bg-slate-100", "text-slate-600", "border-slate-200")
        }
      } else {
        el.classList.remove("border-primary", "bg-blue-50/50", "ring-1", "ring-primary/20", "ring-primary")
        el.classList.add("border-slate-200", "bg-white")
        const badge = el.querySelector("div")
        if (badge) {
          badge.classList.remove("bg-primary", "text-white", "border-primary")
          badge.classList.add("bg-slate-100", "text-slate-600", "border-slate-200")
        }
      }
    })

    // Update Content Visibility
    this.contentTargets.forEach((el, i) => {
      if (i === index) {
        el.classList.remove("hidden")
      } else {
        el.classList.add("hidden")
      }
    })
  }

  get hasSelectedStep() {
    return this.stepTargets.some(el => el.getAttribute("aria-current") === "step")
  }
}

