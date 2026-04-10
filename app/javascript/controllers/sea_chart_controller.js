import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["node", "line", "mapArea", "fullscreenButton", "modifyButton", "editTools", "editLink"]
  static values = { addMode: Boolean, editMode: Boolean }

  connect() {
    this.activeNode = null;
    this.offsetX = 0;
    this.offsetY = 0;

    // Setup drag
    this.boundDrag = this.drag.bind(this);
    this.boundDragEnd = this.dragEnd.bind(this);
    this.boundFullscreenChange = this.syncFullscreenButton.bind(this);

    document.addEventListener("mousemove", this.boundDrag, { passive: false });
    document.addEventListener("mouseup", this.boundDragEnd);
    document.addEventListener("touchmove", this.boundDrag, { passive: false });
    document.addEventListener("touchend", this.boundDragEnd);
    document.addEventListener("fullscreenchange", this.boundFullscreenChange);

    this.syncAddMode()
    this.syncEditMode()
    this.syncFullscreenButton()
  }

  // Crea un nuovo approdo quando si clicca il mare libero.
  mapClicked(event) {
    if (!this.addModeValue) return; // Se non stiamo aggiungendo fa un bel niente
    if (event.target.closest('[data-sea-chart-target="node"]')) return;

    const parentRect = this.mapAreaTarget.getBoundingClientRect();
    const x = Math.round(event.clientX - parentRect.left);
    const y = Math.round(event.clientY - parentRect.top);

    // Iniezione diretta tramite Hotwire/Turbo Frame!
    const frame = document.getElementById("port_modal");
    if (frame) {
      frame.src = `/creator/ports/new?x=${x}&y=${y}`;
    } else {
      window.location.href = `/creator/ports/new?x=${x}&y=${y}`; // Fallback se il frame manca
    }
  }

  disconnect() {
    document.removeEventListener("mousemove", this.boundDrag);
    document.removeEventListener("mouseup", this.boundDragEnd);
    document.removeEventListener("touchmove", this.boundDrag);
    document.removeEventListener("touchend", this.boundDragEnd);
    document.removeEventListener("fullscreenchange", this.boundFullscreenChange);
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
    if (this.addModeValue) {
      window.location.href = "/creator/carta_nautica"
      return
    }

    this.editModeValue = !this.editModeValue
    this.syncEditMode()
  }

  syncAddMode() {
    if (!this.hasMapAreaTarget) return

    if (this.addModeValue) {
      this.mapAreaTarget.style.cursor = "crosshair"
      this.mapAreaTarget.style.backgroundColor = "#bae6fd"
    } else {
      this.mapAreaTarget.style.cursor = "default"
      this.mapAreaTarget.style.backgroundColor = "#e0f2fe"
    }
  }

  syncEditMode() {
    if (this.hasModifyButtonTarget) {
      this.modifyButtonTarget.textContent = this.editModeValue ? "Chiudi modifica" : "Modifica"
    }

    if (this.hasEditToolsTarget) {
      this.editToolsTarget.hidden = !this.editModeValue
    }

    if (this.hasEditLinkTarget) {
      this.editLinkTargets.forEach((link) => {
        link.hidden = !this.editModeValue
      })
    }

    if (this.hasNodeTarget) {
      this.nodeTargets.forEach((node) => {
        node.style.cursor = this.editModeValue ? "grab" : "default"
      })
    }
  }

  syncFullscreenButton() {
    if (!this.hasFullscreenButtonTarget) return;

    if (!document.fullscreenEnabled) {
      this.fullscreenButtonTarget.disabled = true;
      this.fullscreenButtonTarget.textContent = "Full screen non supportato";
      return;
    }

    this.fullscreenButtonTarget.disabled = false;
    this.fullscreenButtonTarget.textContent =
      document.fullscreenElement === this.mapAreaTarget ? "Esci da full screen" : "Full screen";
  }

  dragStart(event) {
    if (!this.editModeValue) return;
    // Ignoriamo la cattura se si sta cliccando sulla pennetta dell'edit
    if (event.target.tagName.toLowerCase() === 'a' || event.target.closest('a')) return;

    event.preventDefault();
    this.activeNode = event.currentTarget;
    this.activeNode.style.cursor = "grabbing";
    this.activeNode.style.zIndex = 1000;
    this.activeNode.style.transform = "scale(1.05)";
    
    // Supporto universale mouse e touch
    const clientX = event.clientX || (event.touches && event.touches[0].clientX);
    const clientY = event.clientY || (event.touches && event.touches[0].clientY);

    const rect = this.activeNode.getBoundingClientRect();

    // Calcoliamo dove ha premuto l'utente all'interno del nodo stesso
    this.offsetX = clientX - rect.left;
    this.offsetY = clientY - rect.top;
  }

  drag(event) {
    if (!this.activeNode) return;
    event.preventDefault(); // Previene lo scrolling della pagina su mobile

    const clientX = event.clientX || (event.touches && event.touches[0].clientX);
    const clientY = event.clientY || (event.touches && event.touches[0].clientY);

    const parentRect = this.mapAreaTarget.getBoundingClientRect();

    // La nuova posizione del nodo relativa al container
    let newX = clientX - parentRect.left - this.offsetX;
    let newY = clientY - parentRect.top - this.offsetY;

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

    this.lineTargets.forEach(line => {
      if (line.dataset.sourceId === portId) {
        line.setAttribute("x1", centerX);
        line.setAttribute("y1", centerY);
      }
      if (line.dataset.targetId === portId) {
        line.setAttribute("x2", centerX);
        line.setAttribute("y2", centerY);
      }
    });
  }

  dragEnd(event) {
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
    console.log(`📡 Salvataggio in DB del Porto [${id}] in -> X: ${x}, Y: ${y}`);
    
    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    if (!csrfTokenMeta) return;

    fetch(`/creator/ports/${id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfTokenMeta.content,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        port: {
          x: x,
          y: y
        }
      })
    }).then(response => {
      if (!response.ok) {
        console.error("❌ Coordinate non salvate correttamente", response);
      } else {
        console.log("✅ Update posizionale andato a buon fine.");
      }
    }).catch(err => console.error("Errore di rete durante salvataggio:", err));
  }
}
