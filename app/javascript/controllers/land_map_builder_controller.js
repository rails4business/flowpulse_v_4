import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "svg",
    "placementMarker",
    "previewLine",
    "lineX",
    "lineY",
    "lineForm",
    "lineHint",
    "lineModal",
    "linePanel",
    "lineTitle",
    "stationX",
    "stationY",
    "stationForm",
    "stationHint",
    "stationModal",
    "stationPanel",
    "stationTitle",
    "contextMenu"
  ]
  static values = { mode: String, clearSelectionPath: String }

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
    this.boundDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("click", this.boundDocumentClick)
    this.resetPlacementState()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    document.removeEventListener("click", this.boundDocumentClick)
  }

  resetPlacementState() {
    if (this.hasPlacementMarkerTarget) {
      this.placementMarkerTarget.classList.add("hidden")
    }

    if (this.hasPreviewLineTarget) {
      this.previewLineTarget.classList.add("hidden")
    }

    if (this.modeValue === "new_line") {
      if (this.hasLineXTarget) this.lineXTarget.value = ""
      if (this.hasLineYTarget) this.lineYTarget.value = ""
      if (this.hasLineHintTarget) this.lineHintTarget.textContent = "In attesa del primo click sulla mappa."
      if (this.hasLineTitleTarget) this.lineTitleTarget.textContent = "Nuova Line"
      this.toggleLineForm(false)
      this.toggleLineModal(false)
    }

    if (this.modeValue === "new_station") {
      if (this.hasStationXTarget) this.stationXTarget.value = ""
      if (this.hasStationYTarget) this.stationYTarget.value = ""
      if (this.hasStationHintTarget) this.stationHintTarget.textContent = "In attesa del click sulla mappa."
      if (this.hasStationTitleTarget) this.stationTitleTarget.textContent = "Nuova Station"
      this.toggleStationForm(false)
      this.toggleStationModal(false)
    }
  }

  pick(event) {
    if (!this.hasSvgTarget) return

    const svg = this.svgTarget
    const point = svg.createSVGPoint()
    point.x = event.clientX
    point.y = event.clientY

    const localPoint = point.matrixTransform(svg.getScreenCTM().inverse())
    const x = Math.round(localPoint.x)
    const y = Math.round(localPoint.y)

    this.showPlacementMarker(x, y)
    this.updatePreviewLine(x, y)

    if (this.modeValue === "new_line" && this.hasLineXTarget && this.hasLineYTarget) {
      this.lineXTarget.value = x
      this.lineYTarget.value = y
      this.openLineModal()
      if (this.hasLineHintTarget) this.lineHintTarget.textContent = "Compila i dati della line e dell'experience iniziale."
      if (this.hasLineTitleTarget) this.lineTitleTarget.textContent = `Nuova Line in x ${x} · y ${y}`
    }

    if (this.modeValue === "new_station" && this.hasStationXTarget && this.hasStationYTarget) {
      this.stationXTarget.value = x
      this.stationYTarget.value = y
      this.openStationModal()
      if (this.hasStationHintTarget) this.stationHintTarget.textContent = "Compila i dati della station e scegli o crea l'experience."
      if (this.hasStationTitleTarget) this.stationTitleTarget.textContent = `Nuova Station in x ${x} · y ${y}`
    }
  }

  move(event) {
    if (!this.hasSvgTarget) return
    if (!["new_line", "new_station"].includes(this.modeValue)) return

    const { x, y } = this.localCoordinates(event)
    this.showPlacementMarker(x, y)

    if (this.modeValue === "new_station") {
      this.updatePreviewLine(x, y)
    }
  }

  leave() {
    if (this.modeValue === "new_line" || this.modeValue === "new_station") {
      if (this.hasPlacementMarkerTarget) {
        this.placementMarkerTarget.classList.add("hidden")
      }
    }

    if (this.modeValue === "new_station" && this.hasPreviewLineTarget) {
      this.previewLineTarget.classList.add("hidden")
    }
  }

  closeModal(event) {
    const modal = event.currentTarget
    if (event.target !== modal) return

    window.location.href = event.currentTarget.dataset.closePath
  }

  handleKeydown(event) {
    if (event.key !== "Escape") return

    if (!this.hasLineModalTarget && !this.hasStationModalTarget) return

    if (this.hasLineModalTarget && !this.lineModalTarget.classList.contains("hidden")) {
      window.location.href = this.lineModalTarget.dataset.closePath
      return
    }

    if (this.hasStationModalTarget && !this.stationModalTarget.classList.contains("hidden")) {
      window.location.href = this.stationModalTarget.dataset.closePath
    }
  }

  handleDocumentClick(event) {
    if (this.modeValue) return
    if (!this.hasContextMenuTarget) return
    if (!this.hasClearSelectionPathValue) return
    if (this.contextMenuTarget.contains(event.target)) return
    if (event.target.closest("a, button, input, select, textarea, label")) return

    window.location.href = this.clearSelectionPathValue
  }

  toggleLineForm(forceVisible = null) {
    if (!this.hasLineFormTarget) return

    const visible = forceVisible === null ? this.lineXTarget?.value && this.lineYTarget?.value : forceVisible
    this.lineFormTargets.forEach((element) => element.classList.toggle("hidden", !visible))
  }

  toggleStationForm(forceVisible = null) {
    if (!this.hasStationFormTarget) return

    const visible = forceVisible === null ? this.stationXTarget?.value && this.stationYTarget?.value : forceVisible
    this.stationFormTargets.forEach((element) => element.classList.toggle("hidden", !visible))
  }

  toggleLineModal(forceVisible = null) {
    if (!this.hasLineModalTarget) return

    const visible = forceVisible === null ? this.lineXTarget?.value && this.lineYTarget?.value : forceVisible
    this.lineModalTarget.classList.toggle("hidden", !visible)
    this.lineModalTarget.classList.toggle("flex", !!visible)
  }

  toggleStationModal(forceVisible = null) {
    if (!this.hasStationModalTarget) return

    const visible = forceVisible === null ? this.stationXTarget?.value && this.stationYTarget?.value : forceVisible
    this.stationModalTarget.classList.toggle("hidden", !visible)
    this.stationModalTarget.classList.toggle("flex", !!visible)
  }

  showPlacementMarker(x, y) {
    if (!this.hasPlacementMarkerTarget) return

    this.placementMarkerTarget.setAttribute("cx", x)
    this.placementMarkerTarget.setAttribute("cy", y)
    this.placementMarkerTarget.classList.remove("hidden")
  }

  updatePreviewLine(x, y) {
    if (!this.hasPreviewLineTarget) return

    const originX = this.previewLineTarget.dataset.originX
    const originY = this.previewLineTarget.dataset.originY
    if (!originX || !originY) return

    this.previewLineTarget.setAttribute("x1", originX)
    this.previewLineTarget.setAttribute("y1", originY)
    this.previewLineTarget.setAttribute("x2", x)
    this.previewLineTarget.setAttribute("y2", y)
    this.previewLineTarget.classList.remove("hidden")
  }

  localCoordinates(event) {
    const point = this.svgTarget.createSVGPoint()
    point.x = event.clientX
    point.y = event.clientY

    const localPoint = point.matrixTransform(this.svgTarget.getScreenCTM().inverse())
    return {
      x: Math.round(localPoint.x),
      y: Math.round(localPoint.y)
    }
  }

  openLineModal() {
    this.toggleLineModal(true)
    this.toggleLineForm(true)
  }

  openStationModal() {
    this.toggleStationModal(true)
    this.toggleStationForm(true)
  }
}
