import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["existing", "new", "existingInput", "newInput", "mode", "existingButton", "newButton"]

  connect() {
    this.sync()
  }

  setMode(event) {
    this.modeTarget.value = event.currentTarget.dataset.mode
    this.sync()
  }

  sync() {
    const mode = this.modeTarget.value
    const useExisting = mode === "existing"

    this.existingTarget.classList.toggle("hidden", !useExisting)
    this.newTarget.classList.toggle("hidden", useExisting)

    if (this.hasExistingButtonTarget) {
      this.existingButtonTarget.className = useExisting
        ? "inline-flex items-center justify-center rounded-full bg-emerald-600 px-4 py-2 text-xs font-black text-white shadow-sm"
        : "inline-flex items-center justify-center rounded-full bg-white px-4 py-2 text-xs font-black text-slate-600 border border-slate-200"
    }

    if (this.hasNewButtonTarget) {
      this.newButtonTarget.className = useExisting
        ? "inline-flex items-center justify-center rounded-full bg-white px-4 py-2 text-xs font-black text-slate-600 border border-slate-200"
        : "inline-flex items-center justify-center rounded-full bg-emerald-600 px-4 py-2 text-xs font-black text-white shadow-sm"
    }

    if (this.hasExistingInputTarget) {
      this.existingInputTargets.forEach((input) => {
        input.disabled = !useExisting
      })
    }

    if (this.hasNewInputTarget) {
      this.newInputTargets.forEach((input) => {
        input.disabled = useExisting
      })
    }
  }
}
