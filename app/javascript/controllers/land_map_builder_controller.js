import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "svg",
    "placementMarker",
    "candidateMarker",
    "previewLine",
    "lineX",
    "lineY",
    "lineForm",
    "lineHint",
    "lineModal",
    "linePanel",
    "lineTitle",
    "lineSourceStation",
    "lineInitialKind",
    "lineInitialName",
    "lineAttachSummary",
    "lineFreeSummary",
    "stationX",
    "stationY",
    "stationSourceStation",
    "stationRelativePosition",
    "stationLinkStation",
    "stationSourceOptions",
    "stationBeforeButton",
    "stationAfterButton",
    "stationModeSummary",
    "stationForm",
    "stationHint",
    "stationModal",
    "stationPanel",
    "stationTitle",
    "contextMenu"
  ]
  static values = { mode: String, moveMode: Boolean, clearSelectionPath: String, stations: String, selectedLineId: Number }

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
    this.boundDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("click", this.boundDocumentClick)
    this.candidateStation = null
    this.dragState = null
    this.pendingMoveSelection = null
    this.liveStationPositions = {}
    this.stationNodes = this.parseStations()
    this.initialStationSourceId = this.hasStationSourceStationTarget ? this.stationSourceStationTarget.value : ""
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

    if (this.hasCandidateMarkerTarget) {
      this.candidateMarkerTarget.classList.add("hidden")
    }

    this.candidateStation = null

    if (this.modeValue === "new_line") {
      if (this.hasLineXTarget) this.lineXTarget.value = ""
      if (this.hasLineYTarget) this.lineYTarget.value = ""
      if (this.hasLineHintTarget) this.lineHintTarget.textContent = "In attesa del primo click sulla mappa."
      if (this.hasLineTitleTarget) this.lineTitleTarget.textContent = "Nuova Line"
      if (this.hasLineSourceStationTarget) this.lineSourceStationTarget.value = ""
      this.syncLineModeUI(false)
      this.toggleLineForm(false)
      this.toggleLineModal(false)
    }

    if (this.modeValue === "new_station") {
      if (this.hasStationXTarget) this.stationXTarget.value = ""
      if (this.hasStationYTarget) this.stationYTarget.value = ""
      if (this.hasStationSourceStationTarget) this.stationSourceStationTarget.value = this.initialStationSourceId || ""
      if (this.hasStationLinkStationTarget) this.stationLinkStationTarget.value = ""
      if (this.hasStationRelativePositionTarget && !this.stationRelativePositionTarget.value) this.stationRelativePositionTarget.value = "after"
      if (this.hasStationHintTarget) this.stationHintTarget.textContent = "In attesa del click sulla mappa."
      if (this.hasStationTitleTarget) this.stationTitleTarget.textContent = "Nuova Station"
      this.syncStationModeUI()
      this.toggleStationForm(false)
      this.toggleStationModal(false)
      this.autoOpenStationModalIfSegmentInsert()
    }
  }

  pick(event) {
    if (!this.hasSvgTarget) return
    if (this.dragState) return

    const svg = this.svgTarget
    const point = svg.createSVGPoint()
    point.x = event.clientX
    point.y = event.clientY

    const localPoint = point.matrixTransform(svg.getScreenCTM().inverse())
    const x = Math.round(localPoint.x)
    const y = Math.round(localPoint.y)

    const candidate = this.findCandidateStation(x, y)
    const stationSourceNode = this.modeValue === "new_station" ? this.stationSourceNode() : null
    const externalAttachCandidate = this.modeValue === "new_station" ? this.stationExternalAttachCandidate(stationSourceNode, candidate) : null
    this.showPlacementMarker(x, y, !candidate)
    this.showCandidateMarker(candidate)

    if (this.modeValue === "new_line" && this.hasLineXTarget && this.hasLineYTarget) {
      this.lineXTarget.value = x
      this.lineYTarget.value = y
      if (this.hasLineSourceStationTarget) this.lineSourceStationTarget.value = candidate ? candidate.primaryStationId : ""
      this.syncLineModeUI(!!candidate)
      this.updatePreviewLine(x, y, candidate)
      this.openLineModal()
      if (this.hasLineHintTarget) {
        this.lineHintTarget.textContent = candidate
          ? `Compila i dati della line. La prima station sara' collegata a ${candidate.name}.`
          : "Compila i dati della line e della sua prima station principale."
      }
      if (this.hasLineTitleTarget) this.lineTitleTarget.textContent = `Nuova Line in x ${x} · y ${y}`
    }

    if (this.modeValue === "new_station" && this.hasStationXTarget && this.hasStationYTarget) {
      const targetX = externalAttachCandidate ? externalAttachCandidate.x : x
      const targetY = externalAttachCandidate ? externalAttachCandidate.y : y
      this.stationXTarget.value = targetX
      this.stationYTarget.value = targetY
      if (this.hasStationSourceStationTarget && !this.stationSourceStationTarget.value && candidate) {
        this.stationSourceStationTarget.value = candidate.id
      }
      if (this.hasStationLinkStationTarget) {
        this.stationLinkStationTarget.value = externalAttachCandidate ? externalAttachCandidate.primaryStationId : ""
      }
      this.updatePreviewLine(targetX, targetY, this.stationSourceNode(candidate))
      this.openStationModal()
      if (this.hasStationHintTarget) {
        this.stationHintTarget.textContent = this.stationCreationHint(this.stationSourceNode(candidate), targetX, targetY, externalAttachCandidate)
      }
      if (this.hasStationTitleTarget) this.stationTitleTarget.textContent = `Nuova Station in x ${targetX} · y ${targetY}`
    }
  }

  move(event) {
    if (!this.hasSvgTarget) return
    if (this.dragState) {
      this.updateDrag(event)
      return
    }
    if (!["new_line", "new_station"].includes(this.modeValue)) return

    const { x, y } = this.localCoordinates(event)
    const candidate = this.findCandidateStation(x, y)
    const stationSourceNode = this.modeValue === "new_station" ? this.stationSourceNode() : null
    const externalAttachCandidate = this.modeValue === "new_station" ? this.stationExternalAttachCandidate(stationSourceNode, candidate) : null
    this.showPlacementMarker(x, y, !candidate)
    this.showCandidateMarker(candidate)

    if (this.modeValue === "new_line" || this.modeValue === "new_station") {
      const previewX = externalAttachCandidate ? externalAttachCandidate.x : x
      const previewY = externalAttachCandidate ? externalAttachCandidate.y : y
      this.updatePreviewLine(previewX, previewY, this.modeValue === "new_station" ? stationSourceNode : candidate)
    }

    if (this.modeValue === "new_line" && this.hasLineHintTarget) {
      if (this.hasLineSourceStationTarget) this.lineSourceStationTarget.value = candidate ? candidate.primaryStationId : ""
      this.syncLineModeUI(!!candidate)
      this.lineHintTarget.textContent = candidate
        ? `Se clicchi qui, la nuova line partira' da ${candidate.name}.`
        : "Se clicchi qui, la nuova line nascera' da un punto libero della mappa."
    }

    if (this.modeValue === "new_station" && this.hasStationHintTarget) {
      if (this.hasStationLinkStationTarget) {
        this.stationLinkStationTarget.value = externalAttachCandidate ? externalAttachCandidate.primaryStationId : ""
      }
      this.stationHintTarget.textContent = this.stationPlacementHint(stationSourceNode, externalAttachCandidate)
    }
  }

  setStationRelativePosition(event) {
    if (!this.hasStationRelativePositionTarget) return

    this.stationRelativePositionTarget.value = event.currentTarget.dataset.stationRelativePosition
    this.syncStationModeUI()
    const sourceNode = this.stationSourceNode()
    const insertionTarget = this.stationInsertionTarget(sourceNode)

    if (insertionTarget && sourceNode && this.hasStationXTarget && this.hasStationYTarget) {
      const x = Math.round((sourceNode.x + insertionTarget.x) / 2)
      const y = Math.round((sourceNode.y + insertionTarget.y) / 2)
      this.stationXTarget.value = x
      this.stationYTarget.value = y
      this.showPlacementMarker(x, y, true)
      this.updatePreviewLine(x, y, sourceNode)
      if (this.hasStationHintTarget) this.stationHintTarget.textContent = this.stationCreationHint(sourceNode, x, y)
      if (this.hasStationTitleTarget) this.stationTitleTarget.textContent = `Nuova Station in x ${x} · y ${y}`
      this.openStationModal()
      return
    }

    if (this.hasStationXTarget && this.hasStationYTarget && this.stationXTarget.value && this.stationYTarget.value) {
      this.updatePreviewLine(Number(this.stationXTarget.value), Number(this.stationYTarget.value), sourceNode)
    }
  }

  leave() {
    if (this.dragState) return

    if (this.modeValue === "new_line" || this.modeValue === "new_station") {
      if (this.hasPlacementMarkerTarget) {
        this.placementMarkerTarget.classList.add("hidden")
      }
      if (this.hasCandidateMarkerTarget) {
        this.candidateMarkerTarget.classList.add("hidden")
      }
    }

    if ((this.modeValue === "new_line" || this.modeValue === "new_station") && this.hasPreviewLineTarget) {
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
    if (this.dragState) return
    if (this.modeValue) return
    if (!this.hasContextMenuTarget) return
    if (!this.hasClearSelectionPathValue) return
    if (this.contextMenuTarget.contains(event.target)) return
    if (event.target.closest("a, button, input, select, textarea, label")) return

    window.location.href = this.clearSelectionPathValue
  }

  backgroundClick(event) {
    if (this.dragState) return
    if (this.modeValue) return
    if (!this.hasClearSelectionPathValue) return
    if (event.target.closest("a")) return

    window.location.href = this.clearSelectionPathValue
  }

  stationMouseDown(event) {
    if (!this.moveModeValue) return

    const link = event.currentTarget
    const stationId = Number(link.dataset.stationId)
    event.preventDefault()
    if (!stationId) return

    this.pendingMoveSelection = {
      stationId,
      x: Number(link.dataset.stationX),
      y: Number(link.dataset.stationY),
      href: link.getAttribute("href") || link.getAttribute("xlink:href"),
      repositionPath: link.dataset.repositionPath,
      startClientX: event.clientX,
      startClientY: event.clientY,
      dragging: false
    }

    this.boundPendingMove = this.handlePendingMove.bind(this)
    this.boundPendingUp = this.handlePendingUp.bind(this)
    document.addEventListener("mousemove", this.boundPendingMove)
    document.addEventListener("mouseup", this.boundPendingUp)
  }

  startDrag(event) {
    event?.preventDefault()
    if (!this.hasSvgTarget) return
    const selectedStationLink = document.querySelector(`a[data-station-id="${this.currentSelectedStationId()}"]`)
    if (!selectedStationLink) return

    const stationId = Number(selectedStationLink.dataset.stationId)
    const x = Number(selectedStationLink.dataset.stationX)
    const y = Number(selectedStationLink.dataset.stationY)
    const repositionPath = selectedStationLink.dataset.repositionPath
    const href = selectedStationLink.getAttribute("href") || selectedStationLink.getAttribute("xlink:href")

    this.beginDrag(stationId, x, y, repositionPath, href)
  }

  updateDrag(event) {
    if (!this.dragState || !this.hasSvgTarget) return

    const { x, y } = this.localCoordinates(event)
    this.dragState.x = x
    this.dragState.y = y
    this.applyLiveDrag(x - this.dragState.originX, y - this.dragState.originY)
    this.showPlacementMarker(x, y, true)
    this.showCandidateMarker({ x, y })
  }

  async finishDrag(event) {
    if (!this.dragState || !this.dragState.repositionPath) return

    document.removeEventListener("mousemove", this.boundDragMove)
    document.removeEventListener("mouseup", this.boundDragEnd)

    const { x, y } = this.localCoordinates(event)
    const path = this.dragState.repositionPath

    try {
      const response = await fetch(path, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "",
          "Accept": "application/json"
        },
        body: JSON.stringify({
          map_x: x,
          map_y: y
        })
      })

      if (!response.ok) throw new Error("reposition failed")
      window.location.href = this.dragState.returnHref || window.location.href
    } catch (_error) {
      window.location.href = this.dragState.returnHref || window.location.href
    }
  }

  currentSelectedStationId() {
    const stationIdParam = new URL(window.location.href).searchParams.get("station_id")
    return stationIdParam ? Number(stationIdParam) : null
  }

  beginDrag(stationId, x, y, repositionPath, returnHref = null) {
    if (!stationId || !this.hasSvgTarget || !repositionPath) return

    this.dragState = {
      stationId,
      repositionPath,
      returnHref,
      originX: x,
      originY: y,
      movingStationIds: this.movingStationIdsFor(stationId)
    }
    this.liveStationPositions = this.currentStationPositions()
    this.showPlacementMarker(x, y, true)
    this.showCandidateMarker({ x, y })

    this.boundDragMove = this.updateDrag.bind(this)
    this.boundDragEnd = this.finishDrag.bind(this)
    document.addEventListener("mousemove", this.boundDragMove)
    document.addEventListener("mouseup", this.boundDragEnd)
  }

  handlePendingMove(event) {
    if (!this.pendingMoveSelection) return

    const dx = event.clientX - this.pendingMoveSelection.startClientX
    const dy = event.clientY - this.pendingMoveSelection.startClientY
    if (Math.hypot(dx, dy) < 6) return

    this.pendingMoveSelection.dragging = true
    const pending = this.pendingMoveSelection
    this.clearPendingMoveListeners()
    this.pendingMoveSelection = null
    this.beginDrag(pending.stationId, pending.x, pending.y, pending.repositionPath, pending.href)
    this.updateDrag(event)
  }

  handlePendingUp() {
    if (!this.pendingMoveSelection) return

    const pending = this.pendingMoveSelection
    this.clearPendingMoveListeners()
    this.pendingMoveSelection = null
    if (pending.href) {
      window.location.href = pending.href
    }
  }

  clearPendingMoveListeners() {
    document.removeEventListener("mousemove", this.boundPendingMove)
    document.removeEventListener("mouseup", this.boundPendingUp)
  }

  movingStationIdsFor(stationId) {
    const node = document.querySelector(`[data-station-id="${stationId}"]`)
    if (!node) return [stationId]

    const primaryStationId = Number(node.dataset.primaryStationId || stationId)
    return Array.from(document.querySelectorAll(`[data-primary-station-id="${primaryStationId}"]`))
      .map((element) => Number(element.dataset.stationId))
      .filter((id) => Number.isFinite(id))
  }

  currentStationPositions() {
    return Array.from(document.querySelectorAll("[data-station-id]")).reduce((positions, element) => {
      positions[element.dataset.stationId] = {
        x: Number(element.dataset.stationX),
        y: Number(element.dataset.stationY)
      }
      return positions
    }, {})
  }

  applyLiveDrag(dx, dy) {
    if (!this.dragState) return

    this.dragState.movingStationIds.forEach((stationId) => {
      const element = document.querySelector(`[data-station-id="${stationId}"]`)
      const original = this.liveStationPositions[String(stationId)]
      if (!element || !original) return

      element.setAttribute("transform", `translate(${dx} ${dy})`)
      element.dataset.currentX = String(original.x + dx)
      element.dataset.currentY = String(original.y + dy)
    })

    this.refreshLivePaths()
  }

  refreshLivePaths() {
    document.querySelectorAll("[data-line-station-ids]").forEach((polyline) => {
      const stationIds = (polyline.dataset.lineStationIds || "").split(",").map((id) => id.trim()).filter(Boolean)
      const points = stationIds.map((stationId) => {
        const position = this.currentPositionFor(stationId)
        return position ? `${position.x},${position.y}` : null
      }).filter(Boolean)

      if (points.length) polyline.setAttribute("points", points.join(" "))
    })

    document.querySelectorAll("[data-link-from-id]").forEach((segment) => {
      const from = this.currentPositionFor(segment.dataset.linkFromId)
      const to = this.currentPositionFor(segment.dataset.linkToId)
      if (!from || !to) return

      segment.setAttribute("x1", from.x)
      segment.setAttribute("y1", from.y)
      segment.setAttribute("x2", to.x)
      segment.setAttribute("y2", to.y)
    })

    document.querySelectorAll("[data-shared-group-station-ids]").forEach((polyline) => {
      const stationIds = (polyline.dataset.sharedGroupStationIds || "").split(",").map((id) => id.trim()).filter(Boolean)
      const points = stationIds.map((stationId) => {
        const position = this.currentPositionFor(stationId)
        return position ? `${position.x},${position.y}` : null
      }).filter(Boolean)

      if (points.length) polyline.setAttribute("points", points.join(" "))
    })

    document.querySelectorAll("[data-shared-group-labels]").forEach((labelGroup) => {
      const primaryStationId = labelGroup.dataset.sharedGroupLabels
      const current = this.currentPositionFor(primaryStationId)
      const originX = Number(labelGroup.dataset.labelOriginX)
      const originY = Number(labelGroup.dataset.labelOriginY)
      if (!current || !Number.isFinite(originX) || !Number.isFinite(originY)) return

      labelGroup.setAttribute("transform", `translate(${current.x - originX} ${current.y - originY})`)
    })
  }

  currentPositionFor(stationId) {
    const element = document.querySelector(`[data-station-id="${stationId}"]`)
    if (!element) return null

    const x = Number(element.dataset.currentX || element.dataset.stationX)
    const y = Number(element.dataset.currentY || element.dataset.stationY)
    if (!Number.isFinite(x) || !Number.isFinite(y)) return null

    return { x, y }
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

  showPlacementMarker(x, y, visible = true) {
    if (!this.hasPlacementMarkerTarget) return

    if (!visible) {
      this.placementMarkerTarget.classList.add("hidden")
      return
    }

    this.placementMarkerTarget.setAttribute("cx", x)
    this.placementMarkerTarget.setAttribute("cy", y)
    this.placementMarkerTarget.classList.remove("hidden")
  }

  updatePreviewLine(x, y, candidate = null) {
    if (!this.hasPreviewLineTarget) return
    const originX = candidate ? candidate.x : this.previewLineTarget.dataset.originX
    const originY = candidate ? candidate.y : this.previewLineTarget.dataset.originY
    let targetX = x
    let targetY = y

    if (this.modeValue === "new_station" && candidate) {
      const relativePosition = this.stationRelativePosition()
      if (relativePosition === "before" && candidate.prevX && candidate.prevY) {
        targetX = candidate.prevX
        targetY = candidate.prevY
      } else if (relativePosition === "after" && candidate.nextX && candidate.nextY) {
        targetX = candidate.nextX
        targetY = candidate.nextY
      }
    }

    if (!originX || !originY) return

    this.previewLineTarget.setAttribute("x1", originX)
    this.previewLineTarget.setAttribute("y1", originY)
    this.previewLineTarget.setAttribute("x2", targetX)
    this.previewLineTarget.setAttribute("y2", targetY)
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
    this.syncLineModeUI(this.hasLineSourceStationTarget && this.lineSourceStationTarget.value !== "")
  }

  openStationModal() {
    this.toggleStationModal(true)
    this.toggleStationForm(true)
    this.syncStationModeUI()
  }

  autoOpenStationModalIfSegmentInsert() {
    const sourceNode = this.stationSourceNode()
    if (!sourceNode || !this.hasStationXTarget || !this.hasStationYTarget) return

    const insertionTarget = this.stationInsertionTarget(sourceNode)
    if (!insertionTarget) return

    const x = Math.round((sourceNode.x + insertionTarget.x) / 2)
    const y = Math.round((sourceNode.y + insertionTarget.y) / 2)

    this.stationXTarget.value = x
    this.stationYTarget.value = y
    this.showPlacementMarker(x, y, true)
    this.showCandidateMarker(sourceNode)
    this.updatePreviewLine(x, y, sourceNode)
    this.openStationModal()

    if (this.hasStationHintTarget) {
      this.stationHintTarget.textContent = this.stationCreationHint(sourceNode, x, y)
    }

    if (this.hasStationTitleTarget) {
      this.stationTitleTarget.textContent = `Nuova Station in x ${x} · y ${y}`
    }
  }

  showCandidateMarker(candidate) {
    this.candidateStation = candidate
    if (!this.hasCandidateMarkerTarget) return

    if (!candidate) {
      this.candidateMarkerTarget.classList.add("hidden")
      return
    }

    this.candidateMarkerTarget.setAttribute("cx", candidate.x)
    this.candidateMarkerTarget.setAttribute("cy", candidate.y)
    this.candidateMarkerTarget.classList.remove("hidden")
  }

  findCandidateStation(x, y) {
    if (!this.stationNodes.length) return null

    const threshold = 34
    const eligibleNodes = this.stationNodes.filter((node) => {
      if (this.modeValue === "new_station" && this.hasSelectedLineIdValue) {
        const sourceNode = this.stationSourceNode()
        if (sourceNode && this.stationNeedsFreePlacement(sourceNode)) {
          return node.lineId !== this.selectedLineIdValue
        }

        return node.lineId === this.selectedLineIdValue
      }

      return true
    })

    let best = null
    let bestDistance = threshold

    eligibleNodes.forEach((node) => {
      const distance = Math.hypot(node.x - x, node.y - y)
      if (distance <= bestDistance) {
        best = node
        bestDistance = distance
      }
    })

    return best
  }

  parseStations() {
    if (!this.hasStationsValue) return []

    try {
      return JSON.parse(this.stationsValue)
    } catch (_error) {
      return []
    }
  }

  syncLineModeUI(attached) {
    if (this.hasLineAttachSummaryTarget) {
      this.lineAttachSummaryTargets.forEach((el) => el.classList.toggle("hidden", !attached))
    }

    if (this.hasLineFreeSummaryTarget) {
      this.lineFreeSummaryTargets.forEach((el) => el.classList.toggle("hidden", attached))
    }

    if (this.hasLineInitialKindTarget) {
      this.lineInitialKindTarget.value = attached ? "branch" : "normal"
    }

    if (this.hasLineInitialNameTarget && this.hasLineSourceStationTarget) {
      const currentValue = this.lineInitialNameTarget.value.trim()
      const previousAutoName = this.lineInitialNameTarget.dataset.autoName || ""

      if (currentValue === "" || currentValue === previousAutoName) {
        const autoName = attached && this.candidateStation ? `Collegamento a ${this.candidateStation.name}` : "Inizio"
        this.lineInitialNameTarget.value = autoName
        this.lineInitialNameTarget.dataset.autoName = autoName
      }
    }
  }

  syncStationModeUI() {
    const sourceNode = this.stationSourceNode()
    const hasSource = !!sourceNode
    const relativePosition = this.stationRelativePosition()
    const externalLink = this.hasStationLinkStationTarget ? this.findStationNodeById(this.stationLinkStationTarget.value) : null

    if (this.hasStationSourceOptionsTarget) {
      this.stationSourceOptionsTarget.classList.toggle("hidden", !hasSource)
    }

    if (this.hasStationBeforeButtonTarget) {
      this.toggleSegmentButton(this.stationBeforeButtonTarget, relativePosition === "before")
    }

    if (this.hasStationAfterButtonTarget) {
      this.toggleSegmentButton(this.stationAfterButtonTarget, relativePosition === "after")
    }

    if (this.hasStationModeSummaryTarget) {
      if (!sourceNode) {
        this.stationModeSummaryTarget.textContent = "La nuova station verra' posizionata su un punto libero della mappa."
      } else if (externalLink) {
        this.stationModeSummaryTarget.textContent = `La nuova station verra' agganciata a ${externalLink.name} e ampliera' il nodo condiviso.`
      } else if (relativePosition === "before" && sourceNode.prevX && sourceNode.prevY) {
        this.stationModeSummaryTarget.textContent = `La nuova station verra' inserita tra la precedente e ${sourceNode.name}.`
      } else if (relativePosition === "before") {
        this.stationModeSummaryTarget.textContent = `La nuova station verra' posizionata liberamente prima di ${sourceNode.name}.`
      } else if (sourceNode.nextX && sourceNode.nextY) {
        this.stationModeSummaryTarget.textContent = `La nuova station verra' inserita tra ${sourceNode.name} e la successiva.`
      } else {
        this.stationModeSummaryTarget.textContent = `La nuova station verra' posizionata liberamente dopo ${sourceNode.name}.`
      }
    }
  }

  stationRelativePosition() {
    return this.hasStationRelativePositionTarget ? this.stationRelativePositionTarget.value : "after"
  }

  stationInsertionTarget(sourceNode) {
    if (!sourceNode) return null

    if (this.stationRelativePosition() === "before" && sourceNode.prevX && sourceNode.prevY) {
      return { x: Number(sourceNode.prevX), y: Number(sourceNode.prevY) }
    }

    if (this.stationRelativePosition() === "after" && sourceNode.nextX && sourceNode.nextY) {
      return { x: Number(sourceNode.nextX), y: Number(sourceNode.nextY) }
    }

    return null
  }

  stationSourceNode(fallbackCandidate = null) {
    const sourceId = this.hasStationSourceStationTarget ? this.stationSourceStationTarget.value : ""
    if (sourceId) return this.findStationNodeById(sourceId)
    return fallbackCandidate
  }

  findStationNodeById(id) {
    const normalizedId = Number(id)
    return this.stationNodes.find((node) => node.id === normalizedId) || null
  }

  stationPlacementHint(sourceNode, externalAttachCandidate = null) {
    if (!sourceNode) {
      return "Se clicchi qui, la nuova station si posizionera' su un punto libero della mappa."
    }

    if (externalAttachCandidate) {
      return `Se clicchi qui, la nuova station si aggancera' a ${externalAttachCandidate.name} e ampliera' il nodo condiviso.`
    }

    if (this.stationRelativePosition() === "before") {
      if (sourceNode.prevX && sourceNode.prevY) {
        return `La nuova station verra' inserita automaticamente tra la precedente e ${sourceNode.name}.`
      }
      return `Se clicchi qui, la nuova station verra' posizionata prima di ${sourceNode.name}.`
    }

    if (sourceNode.nextX && sourceNode.nextY) {
      return `La nuova station verra' inserita automaticamente tra ${sourceNode.name} e la successiva.`
    }

    return `Se clicchi qui, la nuova station verra' posizionata dopo ${sourceNode.name}.`
  }

  stationCreationHint(sourceNode, x, y, externalAttachCandidate = null) {
    const title = `Compila i dati della station in x ${x} · y ${y}.`
    if (!sourceNode) {
      return `${title} Il nodo verra' posizionato su un punto libero della mappa.`
    }

    if (externalAttachCandidate) {
      return `${title} Il nodo verra' agganciato a ${externalAttachCandidate.name} per ampliare il gruppo condiviso.`
    }

    if (this.stationRelativePosition() === "before") {
      if (sourceNode.prevX && sourceNode.prevY) {
        return `${title} Il nodo verra' inserito tra la station precedente e ${sourceNode.name}.`
      }
      return `${title} Il nodo verra' posizionato prima di ${sourceNode.name}.`
    }

    if (sourceNode.nextX && sourceNode.nextY) {
      return `${title} Il nodo verra' inserito tra ${sourceNode.name} e la successiva.`
    }

    return `${title} Il nodo verra' posizionato dopo ${sourceNode.name}.`
  }

  stationExternalAttachCandidate(sourceNode, hoverCandidate) {
    if (!sourceNode || !hoverCandidate) return null
    if (!this.stationNeedsFreePlacement(sourceNode)) return null
    if (hoverCandidate.lineId === this.selectedLineIdValue) return null

    return hoverCandidate
  }

  stationNeedsFreePlacement(sourceNode) {
    if (!sourceNode) return true

    if (this.stationRelativePosition() === "before") {
      return !(sourceNode.prevX && sourceNode.prevY)
    }

    return !(sourceNode.nextX && sourceNode.nextY)
  }

  toggleSegmentButton(button, active) {
    button.classList.toggle("bg-emerald-600", active)
    button.classList.toggle("text-white", active)
    button.classList.toggle("shadow-sm", active)
    button.classList.toggle("bg-white", !active)
    button.classList.toggle("text-slate-600", !active)
    button.classList.toggle("border", !active)
    button.classList.toggle("border-slate-200", !active)
  }
}
