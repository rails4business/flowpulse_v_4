import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    if (!document.fullscreenElement) {
      if (this.element.requestFullscreen) {
        this.element.requestFullscreen().catch(err => {
          console.error(`Error attempting to enable full-screen mode: ${err.message} (${err.name})`);
        });
      } else if (this.element.webkitRequestFullscreen) { /* Safari */
        this.element.webkitRequestFullscreen();
      } else if (this.element.msRequestFullscreen) { /* IE11 */
        this.element.msRequestFullscreen();
      }
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.webkitExitFullscreen) { /* Safari */
        document.webkitExitFullscreen();
      } else if (document.msExitFullscreen) { /* IE11 */
        document.msExitFullscreen();
      }
    }
  }
}
