import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "node",
    "line",
    "mapArea",
    "fullscreenButton",
    "modifyButton",
    "editTools",
    "editLink",
    "routeButton",
    "routeHint",
    "previewLine",
    "previewMarker",
    "routeControls",
    "routeDirectionButton",
    "routeDirectionIcon",
    "routeEditButton",
    "routeDeleteButton",
    "routeEditorPanel",
    "routeEditorTitle",
    "routeEditorState",
    "routeEditorCycle",
    "routeDirectionMenu",
    "routeDirectionOption",
  ];
  static values = {
    addMode: Boolean,
    editMode: Boolean,
    chartBrandPortId: Number,
    chartPath: String,
  };

  connect() {
    this.activeNode = null;
    this.offsetX = 0;
    this.offsetY = 0;
    this.panX = 0;
    this.panY = 0;
    this.isPanning = false;
    this.wasPanning = false;
    this.routeSourceId = null;
    this.routeSourceName = null;
    this.routeSourceNode = null;
    this.routeHoveredTargetNode = null;
    this.lastPointerPosition = null;
    this.selectedRouteId = null;
    this.routeControlsPinned = false;
    this.routeDirectionMenuOpen = false;

    // Setup drag
    this.boundDrag = this.drag.bind(this);
    this.boundDragEnd = this.dragEnd.bind(this);
    this.boundFullscreenChange = this.syncFullscreenButton.bind(this);
    this.boundPointerPreview = this.pointerPreview.bind(this);

    document.addEventListener("mousemove", this.boundDrag, { passive: false });
    document.addEventListener("mouseup", this.boundDragEnd);
    document.addEventListener("touchmove", this.boundDrag, { passive: false });
    document.addEventListener("touchend", this.boundDragEnd);
    document.addEventListener("fullscreenchange", this.boundFullscreenChange);
    document.addEventListener("mousemove", this.boundPointerPreview);

    this.syncAllRouteEndpoints();
    this.syncAllRouteArrows();
    this.syncAddMode();
    this.syncEditMode();
    this.syncFullscreenButton();
  }

  // Crea un nuovo approdo quando si clicca il mare libero.
  mapClicked(event) {
    if (this.wasPanning) {
      this.wasPanning = false;
      return;
    }
    if (event.target.closest('[data-sea-chart-target="node"]')) return;
    if (event.target.closest("[data-sea-chart-target='routeControls']")) return;
    if (event.target.closest("[data-sea-chart-target='routeEditorPanel']"))
      return;
    if (!this.addModeValue && !this.routeSourceId) {
      if (this.editModeValue && this.selectedRouteId) this.hideRouteControls();
      return;
    }

    const parentRect = this.mapAreaTarget.getBoundingClientRect();
    const x = Math.round(event.clientX - parentRect.left - this.panX);
    const y = Math.round(event.clientY - parentRect.top - this.panY);

    // Iniezione diretta tramite Hotwire/Turbo Frame!
    const frame = document.getElementById("port_modal");
    const url = new URL("/creator/ports/new", window.location.origin);
    url.searchParams.set("edit", "1");
    url.searchParams.set("x", x);
    url.searchParams.set("y", y);

    if (this.routeSourceId) {
      url.searchParams.set("route_source_port_id", this.routeSourceId);
    }

    if (this.hasChartBrandPortIdValue && this.chartBrandPortIdValue) {
      url.searchParams.set("brand_port_id", this.chartBrandPortIdValue);
    } else {
      url.searchParams.set("brand_root", "1");
    }

    if (frame) {
      frame.src = url.toString();
    } else {
      window.location.href = url.toString(); // Fallback se il frame manca
    }
  }

  mapHovered(event) {
    if (!this.routeSourceId || !this.routeSourceNode) return;
    this.pointerPreview(event);
  }

  nodeHovered(event) {
    if (!this.routeSourceId || !this.routeSourceNode) return;

    const node = event.currentTarget;
    if (String(node.dataset.portId) === String(this.routeSourceId)) return;

    this.routeHoveredTargetNode = node;
    this.updateRoutePreviewToNode(node);
    this.syncRouteCursor();
  }

  nodeHoverLeft() {
    if (!this.routeSourceId) return;

    this.routeHoveredTargetNode = null;
    this.syncRouteCursor();
  }

  pointerPreview(event) {
    if (!this.routeSourceId || !this.routeSourceNode || !this.hasMapAreaTarget)
      return;

    const mapRect = this.mapAreaTarget.getBoundingClientRect();
    const insideMap =
      event.clientX >= mapRect.left &&
      event.clientX <= mapRect.right &&
      event.clientY >= mapRect.top &&
      event.clientY <= mapRect.bottom;

    if (!insideMap) {
      this.routeHoveredTargetNode = null;
      this.syncRoutePreview();
      this.syncRouteCursor();
      return;
    }

    const x = Math.round(event.clientX - mapRect.left - this.panX);
    const y = Math.round(event.clientY - mapRect.top - this.panY);
    this.lastPointerPosition = { x, y };
    const hoveredElement = document.elementFromPoint(
      event.clientX,
      event.clientY,
    );
    const hoveredNode = hoveredElement?.closest?.(
      "[data-sea-chart-target='node']",
    );

    if (
      hoveredNode &&
      String(hoveredNode.dataset.portId) !== String(this.routeSourceId)
    ) {
      this.routeHoveredTargetNode = hoveredNode;
      this.updateRoutePreviewToNode(hoveredNode);
    } else {
      this.routeHoveredTargetNode = null;
      this.updateRoutePreview(x, y);
    }

    this.syncRouteCursor();
  }

  disconnect() {
    document.removeEventListener("mousemove", this.boundDrag);
    document.removeEventListener("mouseup", this.boundDragEnd);
    document.removeEventListener("touchmove", this.boundDrag);
    document.removeEventListener("touchend", this.boundDragEnd);
    document.removeEventListener(
      "fullscreenchange",
      this.boundFullscreenChange,
    );
    document.removeEventListener("mousemove", this.boundPointerPreview);
  }

  async toggleFullscreen() {
    if (!document.fullscreenEnabled) return;

    if (document.fullscreenElement === this.mapAreaTarget) {
      await document.exitFullscreen();
      return;
    }

    await this.mapAreaTarget.requestFullscreen();
  }

  toggleEditMode() {
    const url = new URL(window.location.href);

    if (this.editModeValue) {
      url.searchParams.delete("edit");
      url.searchParams.delete("add_port");
      url.searchParams.delete("route_source_port_id");
    } else {
      url.searchParams.set("edit", "1");
    }

    window.location.href = `${url.pathname}${url.search}${url.hash}`;
  }

  startRoute(event) {
    event.preventDefault();
    event.stopPropagation();
    this.hideRouteControls();

    this.routeSourceId = event.currentTarget.dataset.portId;
    this.routeSourceName = event.currentTarget.dataset.portName;
    this.routeSourceNode = event.currentTarget.closest(
      "[data-sea-chart-target='node']",
    );
    this.routeHoveredTargetNode = null;
    const mapRect = this.mapAreaTarget.getBoundingClientRect();
    const sourceCenter = this.nodeCenter(this.routeSourceNode);
    const initialX = Math.round(event.clientX - mapRect.left - this.panX);
    const initialY = Math.round(event.clientY - mapRect.top - this.panY);

    this.lastPointerPosition = { x: initialX, y: initialY };
    this.syncRouteHint();
    this.syncEditMode();
    this.syncRouteCursor();

    if (this.hasPreviewLineTarget && sourceCenter) {
      this.previewLineTarget.hidden = false;
      this.previewLineTarget.removeAttribute("hidden");
      this.previewLineTarget.setAttribute("x1", sourceCenter.x);
      this.previewLineTarget.setAttribute("y1", sourceCenter.y);
      this.previewLineTarget.setAttribute("x2", initialX);
      this.previewLineTarget.setAttribute("y2", initialY);
    }

    if (this.hasPreviewMarkerTarget) {
      this.previewMarkerTarget.hidden = false;
      this.previewMarkerTarget.style.left = `${initialX - 16}px`;
      this.previewMarkerTarget.style.top = `${initialY - 16}px`;
    }
  }

  nodeClicked(event) {
    const targetNode = event.currentTarget;
    const targetPortId = targetNode.dataset.portId;

    if (!this.routeSourceId) {
      if (this.editModeValue) return;

      const showUrl = targetNode.dataset.portShowUrl;
      if (showUrl) window.location.href = showUrl;
      return;
    }

    if (String(targetPortId) === String(this.routeSourceId)) return;

    this.createSeaRoute(this.routeSourceId, targetPortId);
  }

  async routeLineClicked(event) {
    if (!this.editModeValue || this.routeSourceId) return;

    event.preventDefault();
    event.stopPropagation();

    const line = event.currentTarget;
    const routeId = line.dataset.routeId;
    if (!routeId) return;

    this.selectedRouteId = routeId;
    this.routeControlsPinned = true;
    this.showRouteControls(routeId);
    this.routeEditorPanelTarget.hidden = true;
    this.hideRouteDirectionMenu();
  }

  routeLineEntered(event) {
    if (!this.editModeValue || this.routeSourceId || this.routeControlsPinned)
      return;

    const routeId = event.currentTarget.dataset.routeId;
    if (!routeId) return;

    this.selectedRouteId = routeId;
    this.showRouteControls(routeId);
  }

  routeLineLeft(event) {
    if (!this.editModeValue || this.routeControlsPinned) return;
    if (
      event.relatedTarget?.closest?.("[data-sea-chart-target='routeControls']")
    )
      return;
    if (
      event.relatedTarget?.closest?.(
        "[data-sea-chart-target='routeEditorPanel']",
      )
    )
      return;

    this.hideRouteControls();
  }

  toggleRouteEditor(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.selectedRouteId || !this.hasRouteEditorPanelTarget) return;

    this.routeEditorPanelTarget.hidden = !this.routeEditorPanelTarget.hidden;
    if (!this.routeEditorPanelTarget.hidden)
      this.showRouteEditor(this.selectedRouteId);
  }

  toggleRouteDirectionMenu(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.selectedRouteId) return;

    if (!this.hasRouteDirectionMenuTarget) return;

    this.routeDirectionMenuOpen = !this.routeDirectionMenuOpen;
    if (this.routeDirectionMenuOpen) {
      this.showRouteDirectionMenu(this.selectedRouteId);
    } else {
      this.hideRouteDirectionMenu();
    }
  }

  async setSelectedRouteDirection(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.selectedRouteId) return;

    const directionState = event.currentTarget.dataset.directionState;
    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    if (!csrfTokenMeta || !directionState) return;

    const response = await fetch(
      `/creator/sea_routes/${this.selectedRouteId}/set_direction`,
      {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfTokenMeta.content,
          Accept: "application/json",
        },
        body: JSON.stringify({ direction_state: directionState }),
      },
    );

    if (!response.ok) {
      console.error("Stato della rotta non aggiornato", await response.text());
      return;
    }

    const payload = await response.json();
    this.applySeaRouteState(this.selectedRouteId, payload.sea_route);
    this.hideRouteDirectionMenu();
    this.showRouteControls(this.selectedRouteId);
    if (!this.routeEditorPanelTarget.hidden)
      this.showRouteEditor(this.selectedRouteId);
  }

  async deleteSelectedRoute(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.selectedRouteId) return;

    const confirmed = window.confirm(
      "Sei sicuro di voler eliminare questa rotta?",
    );
    if (!confirmed) return;

    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    if (!csrfTokenMeta) return;

    const response = await fetch(
      `/creator/sea_routes/${this.selectedRouteId}`,
      {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfTokenMeta.content,
          Accept: "application/json",
        },
      },
    );

    if (!response.ok) {
      console.error("Rotta non eliminata", await response.text());
      return;
    }

    this.removeRoute(this.selectedRouteId);
    this.hideRouteControls();
  }

  syncAddMode() {
    if (!this.hasMapAreaTarget) return;

    if (this.addModeValue) {
      this.mapAreaTarget.style.cursor = "crosshair";
      this.mapAreaTarget.style.backgroundColor = "#bae6fd";
    } else {
      this.mapAreaTarget.style.cursor = "default";
      this.mapAreaTarget.style.backgroundColor = "#e0f2fe";
    }
  }

  syncEditMode() {
    if (this.hasModifyButtonTarget) {
      this.modifyButtonTarget.textContent = this.editModeValue ? "✕" : "✎";
      this.modifyButtonTarget.title = this.editModeValue
        ? "Chiudi modifica"
        : "Modalita modifica";
      this.modifyButtonTarget.setAttribute(
        "aria-label",
        this.editModeValue ? "Chiudi modifica" : "Modalita modifica",
      );
      this.modifyButtonTarget.style.background = this.editModeValue
        ? "#0f766e"
        : "";
      this.modifyButtonTarget.style.color = this.editModeValue ? "#ffffff" : "";
      this.modifyButtonTarget.style.borderColor = this.editModeValue
        ? "#0f766e"
        : "";
    }

    if (this.hasEditToolsTarget) {
      this.editToolsTarget.hidden = !this.editModeValue;
    }

    if (this.hasEditLinkTarget) {
      this.editLinkTargets.forEach((link) => {
        link.hidden = !this.editModeValue || !!this.routeSourceId;
      });
    }

    if (this.hasRouteButtonTarget) {
      this.routeButtonTargets.forEach((button) => {
        button.hidden = !this.editModeValue || !!this.routeSourceId;
      });
    }

    if (this.hasNodeTarget) {
      this.nodeTargets.forEach((node) => {
        node.style.cursor = this.editModeValue ? "grab" : "pointer";
      });
    }

    this.syncRouteHint();
    this.syncAddMode();
    this.syncRoutePreview();
    this.syncRouteCursor();
    if (!this.editModeValue) this.hideRouteControls();
  }

  syncFullscreenButton() {
    if (!this.hasFullscreenButtonTarget) return;

    if (!document.fullscreenEnabled) {
      this.fullscreenButtonTarget.disabled = true;
      this.fullscreenButtonTarget.textContent = "⛶";
      this.fullscreenButtonTarget.title = "Full screen non supportato";
      this.fullscreenButtonTarget.setAttribute(
        "aria-label",
        "Full screen non supportato",
      );
      return;
    }

    this.fullscreenButtonTarget.disabled = false;
    this.fullscreenButtonTarget.textContent = "⛶";
    this.fullscreenButtonTarget.title =
      document.fullscreenElement === this.mapAreaTarget
        ? "Esci da full screen"
        : "Full screen";
    this.fullscreenButtonTarget.setAttribute(
      "aria-label",
      document.fullscreenElement === this.mapAreaTarget
        ? "Esci da full screen"
        : "Full screen",
    );
  }

  updatePanTransform() {
    if (this.hasCanvasTarget) {
      this.canvasTarget.style.setProperty("--pan-x", `${this.panX}px`);
      this.canvasTarget.style.setProperty("--pan-y", `${this.panY}px`);
    }

    if (
      this.hasRadarDotsTarget &&
      this.hasRadarViewportTarget &&
      this.hasMapAreaTarget
    ) {
      const scale = 20;
      const mapRect = this.mapAreaTarget.getBoundingClientRect();

      this.radarViewportTarget.style.width = `${mapRect.width / scale}px`;
      this.radarViewportTarget.style.height = `${mapRect.height / scale}px`;

      this.radarDotsTarget.style.setProperty(
        "--radar-pan-x",
        `${this.panX / scale}px`,
      );
      this.radarDotsTarget.style.setProperty(
        "--radar-pan-y",
        `${this.panY / scale}px`,
      );
    }
  }

  panStart(event) {
    if (this.addModeValue || this.routeSourceId) return;
    if (
      event.target.closest('[data-sea-chart-target="node"]') ||
      event.target.closest(".sea-island")
    )
      return;
    if (
      event.target.closest(".hud-element") ||
      event.target.closest('[data-sea-chart-target="routeControls"]')
    )
      return;
    if (
      event.target.closest('[data-sea-chart-target="radar"]') ||
      event.target.closest('[data-action*="radarClick"]') ||
      event.target.closest('[data-sea-chart-target="editTools"]')
    )
      return;

    this.isPanning = true;
    this.wasPanning = false;
    this.panStartX =
      event.clientX || (event.touches && event.touches[0].clientX);
    this.panStartY =
      event.clientY || (event.touches && event.touches[0].clientY);
    this.initialPanX = this.panX;
    this.initialPanY = this.panY;
    this.mapAreaTarget.style.cursor = "grabbing";
  }

  radarClick(event) {
    if (!this.hasRadarViewportTarget) return;
    const radarRect = event.currentTarget.getBoundingClientRect();
    const scale = 20;
    const clickX = event.clientX - radarRect.left;
    const clickY = event.clientY - radarRect.top;

    const canvasCenterX = clickX * scale;
    const canvasCenterY = clickY * scale;

    const mapRect = this.mapAreaTarget.getBoundingClientRect();
    this.panX = -(canvasCenterX - mapRect.width / 2);
    this.panY = -(canvasCenterY - mapRect.height / 2);
    this.updatePanTransform();
  }

  dragStart(event) {
    if (!this.editModeValue) return;
    if (this.routeSourceId) return;
    // Ignoriamo la cattura se si sta cliccando sulla pennetta dell'edit
    if (event.target.tagName.toLowerCase() === "a" || event.target.closest("a"))
      return;
    if (
      event.target.tagName.toLowerCase() === "button" ||
      event.target.closest("button")
    )
      return;

    event.preventDefault();
    this.activeNode = event.currentTarget;
    this.activeNode.style.cursor = "grabbing";
    this.activeNode.style.zIndex = 1000;
    this.activeNode.style.transform = "scale(1.05)";

    // Supporto universale mouse e touch
    const clientX =
      event.clientX || (event.touches && event.touches[0].clientX);
    const clientY =
      event.clientY || (event.touches && event.touches[0].clientY);

    const rect = this.activeNode.getBoundingClientRect();

    // Calcoliamo dove ha premuto l'utente all'interno del nodo stesso
    this.offsetX = clientX - rect.left;
    this.offsetY = clientY - rect.top;
  }

  drag(event) {
    if (this.isPanning) {
      event.preventDefault();
      const clientX =
        event.clientX || (event.touches && event.touches[0].clientX);
      const clientY =
        event.clientY || (event.touches && event.touches[0].clientY);

      this.panX = this.initialPanX + (clientX - this.panStartX);
      this.panY = this.initialPanY + (clientY - this.panStartY);

      if (
        Math.abs(clientX - this.panStartX) > 2 ||
        Math.abs(clientY - this.panStartY) > 2
      ) {
        this.wasPanning = true;
      }

      this.updatePanTransform();
      return;
    }

    if (!this.activeNode) return;
    event.preventDefault(); // Previene lo scrolling della pagina su mobile

    const clientX =
      event.clientX || (event.touches && event.touches[0].clientX);
    const clientY =
      event.clientY || (event.touches && event.touches[0].clientY);

    const parentRect = this.mapAreaTarget.getBoundingClientRect();

    // La nuova posizione del nodo relativa al container
    let newX = clientX - parentRect.left - this.offsetX - this.panX;
    let newY = clientY - parentRect.top - this.offsetY - this.panY;

    this.activeNode.style.left = `${newX}px`;
    this.activeNode.style.top = `${newY}px`;

    // Aggiornamento "Live" di tutte le Rotte Nautiche collegate!
    this.updateRoutingLines(this.activeNode.dataset.portId, newX, newY);
  }

  updateRoutingLines(portId, newX, newY) {
    if (!this.hasLineTarget) return;

    // Aggiungiamo il padding per centrare la corda nel mezzo dell'icona (circa 60px x 40px)
    const centerX = newX + 60;
    const centerY = newY + 40;

    const updatedRouteIds = new Set();

    this.lineTargets.forEach((line) => {
      if (line.dataset.sourceId === portId) {
        line.setAttribute("x1", centerX);
        line.setAttribute("y1", centerY);
        if (line.dataset.routeId) updatedRouteIds.add(line.dataset.routeId);
      }
      if (line.dataset.targetId === portId) {
        line.setAttribute("x2", centerX);
        line.setAttribute("y2", centerY);
        if (line.dataset.routeId) updatedRouteIds.add(line.dataset.routeId);
      }
    });

    updatedRouteIds.forEach((routeId) => this.syncRouteAppearance(routeId));
    if (this.selectedRouteId && updatedRouteIds.has(this.selectedRouteId))
      this.showRouteControls(this.selectedRouteId);
  }

  applySeaRouteState(routeId, seaRoute) {
    if (!seaRoute) return;

    const routeElements = this.element.querySelectorAll(
      `[data-route-id='${routeId}']`,
    );

    routeElements.forEach((element) => {
      if (seaRoute.source_port_id != null)
        element.dataset.sourceId = String(seaRoute.source_port_id);
      if (seaRoute.target_port_id != null)
        element.dataset.targetId = String(seaRoute.target_port_id);
      if (seaRoute.source_port_name != null)
        element.dataset.sourceName = seaRoute.source_port_name;
      if (seaRoute.target_port_name != null)
        element.dataset.targetName = seaRoute.target_port_name;
      if (seaRoute.bidirectional != null)
        element.dataset.bidirectional = String(seaRoute.bidirectional);
    });

    this.syncRouteEndpoints(routeId);
    this.syncRouteAppearance(routeId);
  }

  syncRouteAppearance(routeId) {
    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const bidirectional = visibleLine.dataset.bidirectional === "true";
    const arrowElements = this.element.querySelectorAll(
      `[data-route-arrow-index][data-route-id='${routeId}']`,
    );

    visibleLine.setAttribute(
      "stroke-dasharray",
      bidirectional ? "10,7" : "6,14",
    );
    visibleLine.setAttribute("opacity", bidirectional ? "0.62" : "0.24");

    if (!arrowElements.length) return;

    const x1 = parseFloat(visibleLine.getAttribute("x1"));
    const y1 = parseFloat(visibleLine.getAttribute("y1"));
    const x2 = parseFloat(visibleLine.getAttribute("x2"));
    const y2 = parseFloat(visibleLine.getAttribute("y2"));
    const lineLength = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
    const arrowCount = Math.min(Math.max(Math.floor(lineLength / 52), 3), 10);
    const angle = Math.atan2(y2 - y1, x2 - x1) * (180 / Math.PI);
    const fractions = Array.from(
      { length: arrowCount },
      (_, index) => (index + 1) / (arrowCount + 1),
    );

    arrowElements.forEach((arrowElement) => {
      const index = parseInt(arrowElement.dataset.routeArrowIndex, 10);
      const position = fractions[index] || 0.5;
      const x = Math.round(x1 + (x2 - x1) * position);
      const y = Math.round(y1 + (y2 - y1) * position);

      arrowElement.dataset.bidirectional = String(bidirectional);
      arrowElement.textContent = index % 2 === 0 ? "—" : "➤";
      arrowElement.setAttribute("x", x);
      arrowElement.setAttribute("y", y);
      arrowElement.setAttribute("transform", `rotate(${angle} ${x} ${y})`);
      if (bidirectional) {
        arrowElement.hidden = true;
        arrowElement.setAttribute("hidden", "");
        arrowElement.style.opacity = "0";
      } else {
        arrowElement.hidden = false;
        arrowElement.removeAttribute("hidden");
        arrowElement.style.opacity = "0.95";
      }
    });
  }

  syncAllRouteArrows() {
    const routeIds = new Set();

    this.element
      .querySelectorAll("[data-route-role='visible'][data-route-id]")
      .forEach((line) => {
        routeIds.add(line.dataset.routeId);
      });

    routeIds.forEach((routeId) => this.syncRouteAppearance(routeId));
  }

  syncAllRouteEndpoints() {
    const routeIds = new Set();

    this.element
      .querySelectorAll("[data-route-role='visible'][data-route-id]")
      .forEach((line) => {
        routeIds.add(line.dataset.routeId);
      });

    routeIds.forEach((routeId) => this.syncRouteEndpoints(routeId));
  }

  showRouteControls(routeId) {
    if (!this.hasRouteControlsTarget || !this.editModeValue) return;

    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const x1 = parseFloat(visibleLine.getAttribute("x1"));
    const y1 = parseFloat(visibleLine.getAttribute("y1"));
    const x2 = parseFloat(visibleLine.getAttribute("x2"));
    const y2 = parseFloat(visibleLine.getAttribute("y2"));
    const centerX = Math.round((x1 + x2) / 2);
    const centerY = Math.round((y1 + y2) / 2);

    this.routeControlsTarget.hidden = false;
    this.routeControlsTarget.style.left = `${centerX - 56}px`;
    this.routeControlsTarget.style.top = `${centerY - 46}px`;
    this.syncRouteDirectionButton(routeId);
    if (!this.routeEditorPanelTarget.hidden) this.showRouteEditor(routeId);
  }

  hideRouteControls() {
    this.selectedRouteId = null;
    this.routeControlsPinned = false;
    this.hideRouteDirectionMenu();
    if (!this.hasRouteControlsTarget) return;

    this.routeControlsTarget.hidden = true;
    if (this.hasRouteEditorPanelTarget)
      this.routeEditorPanelTarget.hidden = true;
  }

  showRouteEditor(routeId) {
    if (
      !this.hasRouteEditorPanelTarget ||
      !this.hasRouteEditorTitleTarget ||
      !this.hasRouteEditorStateTarget ||
      !this.hasRouteEditorCycleTarget
    )
      return;

    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const sourceName = visibleLine.dataset.sourceName || "Port";
    const targetName = visibleLine.dataset.targetName || "Port";
    const bidirectional = visibleLine.dataset.bidirectional === "true";
    const x1 = parseFloat(visibleLine.getAttribute("x1"));
    const y1 = parseFloat(visibleLine.getAttribute("y1"));
    const x2 = parseFloat(visibleLine.getAttribute("x2"));
    const y2 = parseFloat(visibleLine.getAttribute("y2"));
    const centerX = Math.round((x1 + x2) / 2);
    const centerY = Math.round((y1 + y2) / 2);

    this.routeEditorTitleTarget.textContent = `${sourceName} - ${targetName}`;
    this.routeEditorStateTarget.textContent = `Stato attuale: ${this.routeStateLabel(bidirectional, sourceName, targetName)}`;
    this.routeEditorCycleTarget.textContent = bidirectional
      ? `La rotta e' neutra. Usa il menu direzione per scegliere ${sourceName} -> ${targetName} oppure ${targetName} -> ${sourceName}.`
      : `La rotta e' orientata da ${sourceName} a ${targetName}. Usa il menu direzione per cambiarla o renderla neutra.`;
    this.routeEditorPanelTarget.hidden = false;
    this.routeEditorPanelTarget.style.left = `${centerX - 120}px`;
    this.routeEditorPanelTarget.style.top = `${centerY + 16}px`;
  }

  routeStateLabel(bidirectional, sourceName, targetName) {
    return bidirectional ? "Neutra" : `${sourceName} -> ${targetName}`;
  }

  syncRouteDirectionButton(routeId) {
    if (
      !this.hasRouteDirectionButtonTarget ||
      !this.hasRouteDirectionIconTarget
    )
      return;

    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const sourceName = visibleLine.dataset.sourceName || "Port";
    const targetName = visibleLine.dataset.targetName || "Port";
    const bidirectional = visibleLine.dataset.bidirectional === "true";

    this.routeDirectionIconTarget.textContent = "⇄";
    this.routeDirectionButtonTarget.title = bidirectional
      ? `Apri il menu direzione. Stato attuale: neutra.`
      : `Apri il menu direzione. Stato attuale: ${sourceName} -> ${targetName}.`;
    this.routeDirectionButtonTarget.setAttribute(
      "aria-label",
      this.routeDirectionButtonTarget.title,
    );
  }

  showRouteDirectionMenu(routeId) {
    if (!this.hasRouteDirectionMenuTarget) return;

    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const sourceName = visibleLine.dataset.sourceName || "Source";
    const targetName = visibleLine.dataset.targetName || "Target";
    const bidirectional = visibleLine.dataset.bidirectional === "true";
    const x1 = parseFloat(visibleLine.getAttribute("x1"));
    const y1 = parseFloat(visibleLine.getAttribute("y1"));
    const x2 = parseFloat(visibleLine.getAttribute("x2"));
    const y2 = parseFloat(visibleLine.getAttribute("y2"));
    const centerX = Math.round((x1 + x2) / 2);
    const centerY = Math.round((y1 + y2) / 2);

    this.routeDirectionMenuTarget.hidden = false;
    this.routeDirectionMenuTarget.style.left = `${centerX - 110}px`;
    this.routeDirectionMenuTarget.style.top = `${centerY - 94}px`;

    this.routeDirectionOptionTargets.forEach((option) => {
      const state = option.dataset.directionState;
      option.textContent =
        state === "bidirectional"
          ? "— Neutra"
          : state === "source_to_target"
            ? `→ ${sourceName} -> ${targetName}`
            : `← ${targetName} -> ${sourceName}`;

      const active =
        (state === "bidirectional" && bidirectional) ||
        (state === "source_to_target" && !bidirectional) ||
        false;

      option.style.background = active
        ? "rgba(15, 118, 110, 0.24)"
        : "transparent";
    });
  }

  hideRouteDirectionMenu() {
    this.routeDirectionMenuOpen = false;
    if (!this.hasRouteDirectionMenuTarget) return;

    this.routeDirectionMenuTarget.hidden = true;
  }

  removeRoute(routeId) {
    this.element
      .querySelectorAll(`[data-route-id='${routeId}']`)
      .forEach((element) => {
        if (element.tagName?.toLowerCase() === "g") {
          element.remove();
        } else if (!element.closest("g[data-route-id]")) {
          element.remove();
        }
      });
  }

  dragEnd(event) {
    if (this.isPanning) {
      this.isPanning = false;
      this.mapAreaTarget.style.cursor = this.addModeValue
        ? "crosshair"
        : "default";
      // wasPanning viene resettato al successivo click
      return;
    }

    if (!this.activeNode) return;

    // Ripristiniamo stili visivi
    this.activeNode.style.cursor = "grab";
    this.activeNode.style.zIndex = "";
    this.activeNode.style.transform = "scale(1)";

    // Recuperiamo id e nuove coordinate finali
    const portId = this.activeNode.dataset.portId;
    const x = parseInt(this.activeNode.style.left);
    const y = parseInt(this.activeNode.style.top);

    this.savePosition(portId, x, y);

    this.activeNode = null;
  }

  savePosition(id, x, y) {
    console.log(
      `📡 Salvataggio in DB del Porto [${id}] in -> X: ${x}, Y: ${y}`,
    );

    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    if (!csrfTokenMeta) return;

    fetch(`/creator/ports/${id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfTokenMeta.content,
        Accept: "application/json",
      },
      body: JSON.stringify({
        port: {
          x: x,
          y: y,
        },
      }),
    })
      .then((response) => {
        if (!response.ok) {
          console.error("❌ Coordinate non salvate correttamente", response);
        } else {
          console.log("✅ Update posizionale andato a buon fine.");
        }
      })
      .catch((err) =>
        console.error("Errore di rete durante salvataggio:", err),
      );
  }

  syncRouteHint() {
    if (!this.hasRouteHintTarget) return;

    if (!this.editModeValue || !this.routeSourceId) {
      this.routeHintTarget.hidden = true;
      this.routeHintTarget.textContent = "";
      return;
    }

    this.routeHintTarget.hidden = false;
    this.routeHintTarget.textContent = `Rotta in creazione da ${this.routeSourceName}. Ora clicca un altro porto oppure il mare per creare una nuova destinazione.`;
  }

  resetRouteMode() {
    this.routeSourceId = null;
    this.routeSourceName = null;
    this.routeSourceNode = null;
    this.routeHoveredTargetNode = null;
    this.lastPointerPosition = null;
    this.syncRouteHint();
    this.syncEditMode();
    this.syncRoutePreview();
    this.syncRouteCursor();
  }

  syncRoutePreview() {
    if (!this.hasPreviewLineTarget || !this.hasPreviewMarkerTarget) return;

    const active =
      this.editModeValue && !!this.routeSourceId && !!this.routeSourceNode;

    this.previewLineTarget.hidden = !active;
    if (!active) this.previewLineTarget.setAttribute("hidden", "");
    this.previewMarkerTarget.hidden = !active;

    if (!active) return;

    const sourceCenter = this.nodeCenter(this.routeSourceNode);
    if (!sourceCenter) return;

    if (this.lastPointerPosition) {
      this.updateRoutePreview(
        this.lastPointerPosition.x,
        this.lastPointerPosition.y,
      );
      return;
    }

    this.previewLineTarget.setAttribute("x1", sourceCenter.x);
    this.previewLineTarget.setAttribute("y1", sourceCenter.y);
    this.previewLineTarget.setAttribute("x2", sourceCenter.x);
    this.previewLineTarget.setAttribute("y2", sourceCenter.y);
    this.previewMarkerTarget.style.left = `${sourceCenter.x - 16}px`;
    this.previewMarkerTarget.style.top = `${sourceCenter.y - 16}px`;
  }

  updateRoutePreview(x, y) {
    if (
      !this.hasPreviewLineTarget ||
      !this.hasPreviewMarkerTarget ||
      !this.routeSourceNode
    )
      return;

    const sourcePoint = this.nodeConnectionPoint(this.routeSourceNode, x, y);
    if (!sourcePoint) return;

    this.previewLineTarget.hidden = false;
    this.previewLineTarget.removeAttribute("hidden");
    this.previewMarkerTarget.hidden = false;
    this.previewLineTarget.setAttribute("x1", sourcePoint.x);
    this.previewLineTarget.setAttribute("y1", sourcePoint.y);
    this.previewLineTarget.setAttribute("x2", x);
    this.previewLineTarget.setAttribute("y2", y);
    this.previewMarkerTarget.style.left = `${x - 16}px`;
    this.previewMarkerTarget.style.top = `${y - 16}px`;
    this.previewMarkerTarget.hidden = false;
  }

  updateRoutePreviewToNode(node) {
    if (
      !this.hasPreviewLineTarget ||
      !this.hasPreviewMarkerTarget ||
      !this.routeSourceNode
    )
      return;

    const targetCenter = this.nodeCenter(node);
    if (!targetCenter) return;

    const sourcePoint = this.nodeConnectionPoint(
      this.routeSourceNode,
      targetCenter.x,
      targetCenter.y,
    );
    const targetPoint = this.nodeConnectionPoint(
      node,
      sourcePoint.x,
      sourcePoint.y,
    );
    if (!sourcePoint || !targetPoint) return;

    this.previewLineTarget.hidden = false;
    this.previewLineTarget.removeAttribute("hidden");
    this.previewMarkerTarget.hidden = true;
    this.previewLineTarget.setAttribute("x1", sourcePoint.x);
    this.previewLineTarget.setAttribute("y1", sourcePoint.y);
    this.previewLineTarget.setAttribute("x2", targetPoint.x);
    this.previewLineTarget.setAttribute("y2", targetPoint.y);
  }

  nodeCenter(node) {
    if (!node || !this.hasMapAreaTarget) return null;

    const nodeRect = node.getBoundingClientRect();
    const mapRect = this.mapAreaTarget.getBoundingClientRect();

    return {
      x: Math.round(
        nodeRect.left - mapRect.left - this.panX + nodeRect.width / 2,
      ),
      y: Math.round(
        nodeRect.top - mapRect.top - this.panY + nodeRect.height / 2,
      ),
    };
  }

  nodeConnectionPoint(node, targetX, targetY) {
    const center = this.nodeCenter(node);
    if (!center) return null;

    const nodeRect = node.getBoundingClientRect();
    const radiusX = Math.max(nodeRect.width / 2 - 10, 24);
    const radiusY = Math.max(nodeRect.height / 2 - 10, 24);
    const deltaX = targetX - center.x;
    const deltaY = targetY - center.y;

    if (deltaX === 0 && deltaY === 0) return center;

    const scale =
      1 /
      Math.sqrt(
        (deltaX * deltaX) / (radiusX * radiusX) +
          (deltaY * deltaY) / (radiusY * radiusY),
      );

    return {
      x: Math.round(center.x + deltaX * scale),
      y: Math.round(center.y + deltaY * scale),
    };
  }

  syncRouteCursor() {
    if (!this.hasMapAreaTarget) return;

    if (this.routeSourceId) {
      this.mapAreaTarget.style.cursor = this.routeHoveredTargetNode
        ? "copy"
        : "crosshair";

      if (this.hasNodeTarget) {
        this.nodeTargets.forEach((node) => {
          if (String(node.dataset.portId) === String(this.routeSourceId)) {
            node.style.cursor = "not-allowed";
          } else if (this.routeHoveredTargetNode === node) {
            node.style.cursor = "copy";
          } else {
            node.style.cursor = "pointer";
          }
        });
      }

      return;
    }

    if (this.hasNodeTarget) {
      this.nodeTargets.forEach((node) => {
        node.style.cursor = this.editModeValue ? "grab" : "pointer";
      });
    }
  }

  async createSeaRoute(sourcePortId, targetPortId) {
    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    if (!csrfTokenMeta) return;

    const response = await fetch("/creator/sea_routes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfTokenMeta.content,
        Accept: "application/json",
      },
      body: JSON.stringify({
        sea_route: {
          source_port_id: sourcePortId,
          target_port_id: targetPortId,
        },
        brand_port_id: this.hasChartBrandPortIdValue
          ? this.chartBrandPortIdValue
          : null,
      }),
    });

    if (!response.ok) {
      console.error("Rotta non creata", await response.text());
      return;
    }

    const payload = await response.json();
    this.resetRouteMode();
    window.location.href =
      payload.redirect_path ||
      (this.hasChartPathValue
        ? this.chartPathValue
        : "/creator/carta_nautica?edit=1");
  }

  syncRouteEndpoints(routeId) {
    const routeLines = this.element.querySelectorAll(
      `[data-route-id='${routeId}']`,
    );
    if (!routeLines.length) return;

    const visibleLine = this.element.querySelector(
      `[data-route-role='visible'][data-route-id='${routeId}']`,
    );
    if (!visibleLine) return;

    const sourceNode = this.nodeTargets.find(
      (node) => node.dataset.portId === visibleLine.dataset.sourceId,
    );
    const targetNode = this.nodeTargets.find(
      (node) => node.dataset.portId === visibleLine.dataset.targetId,
    );
    const sourceCenter = this.nodeCenter(sourceNode);
    const targetCenter = this.nodeCenter(targetNode);
    if (!sourceCenter || !targetCenter) return;

    routeLines.forEach((line) => {
      if (line.tagName?.toLowerCase() !== "line") return;

      line.setAttribute("x1", sourceCenter.x);
      line.setAttribute("y1", sourceCenter.y);
      line.setAttribute("x2", targetCenter.x);
      line.setAttribute("y2", targetCenter.y);
    });
  }
}
